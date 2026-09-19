# frozen_string_literal: true

require "nokogiri"

module Golden
  # Canonical form for a rendered HTML fragment.
  #
  # The golden suite is the operational definition of "parity". Comparing raw
  # render output as strings would make it a test of the *renderer* rather than
  # of the *markup*: no renderer promises a stable attribute order, and an ERB
  # template cannot help emitting indentation where a Phlex `div` call emits
  # none. So a fragment is parsed into a DOM with an HTML5-spec parser and
  # re-serialized in one canonical form. Two fragments are at parity when their
  # canonical forms are byte-identical.
  #
  # Everything the canonical form discards is a difference this suite declares
  # acceptable. That list is short on purpose, and the constants below are its
  # executable copy — the prose lives in
  # design/v2/01-research/golden-suite.md.
  #
  # The canonical form is a fixed point of this transformation: feeding a
  # canonical fragment back through `call` returns it unchanged. That property
  # is what makes a byte comparison against a recorded snapshot a legitimate
  # structural comparison, and `golden_test.rb` asserts it for every snapshot.
  module CanonicalHtml
    INDENT = "  "

    # Whitespace inside these elements is content, not formatting, so the
    # canonical form may not reflow it.
    PRESERVE_WHITESPACE = %w[pre textarea].freeze

    # Raw text elements: the parser does not decode character references inside
    # them, so the canonical form must not introduce any. `Codeblock` renders a
    # `<style>` block, which is why this matters here at all.
    RAW_TEXT = %w[script style].freeze

    # HTML5 void elements — no closing tag, and `<input>` vs `<input />` is a
    # difference the parser erases before we ever see it.
    VOID = %w[
      area base br col embed hr img input link meta source track wbr
    ].freeze

    # HTML5 boolean attributes. `hidden`, `hidden=""` and `hidden="hidden"` are
    # the same attribute to a browser, and the three renderers in play here
    # disagree about which to emit, so all three collapse to the bare name.
    BOOLEAN = %w[
      allowfullscreen async autofocus autoplay checked controls default defer
      disabled formnovalidate hidden inert ismap itemscope loop multiple muted
      nomodule novalidate open playsinline readonly required reversed selected
    ].freeze

    # Attributes whose value is a whitespace-separated token list. The tokens
    # and *their order* are significant; the whitespace between them is not.
    #
    # Order is kept for `class` deliberately. Tailwind resolves two conflicting
    # utilities by source order, and `tailwind_merge` does not remove every
    # conflict (arbitrary variants and `!important` survive it), so sorting the
    # list would let a real regression through. `data-action` keeps order for
    # the same reason: Stimulus invokes handlers in the order they are listed.
    TOKEN_LISTS = %w[class data-action].freeze

    class << self
      def call(html)
        out = +""
        parse(html).each { |node| emit(node, 0, out, :normal) }
        out
      end

      # Every fragment is parsed inside a `<template>`, and that is not
      # cosmetic. In the HTML5 tree construction algorithm a stray `<tr>`,
      # `<td>`, `<option>` or `<li>` at the top level of an "in body" fragment
      # is foster-parented: the element is dropped and only its text survives.
      # RubyUI ships plenty of components whose root element is exactly one of
      # those — TableRow, TableCell, NativeSelectOption, BreadcrumbItem,
      # ToastItem — and a ruler that silently deletes them is worse than no
      # ruler. "In template" insertion mode has no foster parenting, so the
      # wrapper keeps the tree as authored while still going through the real
      # spec parser.
      def parse(html)
        Nokogiri::HTML5.fragment("<template>#{html}</template>").children.first.children
      end

      private

      def emit(node, depth, out, mode)
        case node
        when Nokogiri::XML::Element then emit_element(node, depth, out, mode)
        when Nokogiri::XML::Text then emit_text(node, depth, out, mode)
        when Nokogiri::XML::Comment then nil # invisible to a browser; see the docs
        else
          raise "no canonical form for #{node.class}: #{node.to_s[0, 80].inspect}"
        end
      end

      def emit_element(node, depth, out, mode)
        open = open_tag(node)
        close = VOID.include?(node.name) ? "" : "</#{node.name}>"
        inner_mode = child_mode(node, mode)
        children = significant_children(node, inner_mode)

        if mode != :normal
          # Inside a preserved region we may not add a single character of our
          # own, or the round trip would change the content.
          out << open
          children.each { |child| emit(child, depth, out, inner_mode) }
          out << close
        elsif inner_mode != :normal
          out << (INDENT * depth) << open
          children.each { |child| emit(child, depth, out, inner_mode) }
          out << close << "\n"
        elsif children.empty?
          out << (INDENT * depth) << open << close << "\n"
        else
          out << (INDENT * depth) << open << "\n"
          children.each { |child| emit(child, depth + 1, out, :normal) }
          out << (INDENT * depth) << close << "\n"
        end
      end

      def emit_text(node, depth, out, mode)
        case mode
        when :raw then out << node.text
        when :preserve then out << escape_text(node.text)
        else
          collapsed = collapse(node.text)
          out << (INDENT * depth) << escape_text(collapsed) << "\n" unless collapsed.empty?
        end
      end

      def child_mode(node, mode)
        return mode unless mode == :normal
        return :raw if RAW_TEXT.include?(node.name)
        return :preserve if PRESERVE_WHITESPACE.include?(node.name)
        :normal
      end

      # An element whose only children are comments and formatting whitespace
      # has to canonicalise the same way as an element with no children at all,
      # otherwise `<div></div>` and `<div>\n</div>` — identical to a browser —
      # would compare unequal.
      def significant_children(node, mode)
        return node.children.to_a unless mode == :normal
        node.children.reject { |child| child.comment? || (child.text? && collapse(child.text).empty?) }
      end

      def open_tag(node)
        attributes = node.attribute_nodes.map { |attribute| canonical_attribute(attribute) }.sort_by(&:first)
        return "<#{node.name}>" if attributes.empty?

        rendered = attributes.map do |(name, value)|
          value.nil? ? name : %(#{name}="#{escape_attribute(value)}")
        end
        "<#{node.name} #{rendered.join(" ")}>"
      end

      def canonical_attribute(attribute)
        name = attribute_name(attribute)
        value = attribute.value.to_s

        if BOOLEAN.include?(name) && (value.empty? || value.downcase == name)
          [name, nil]
        elsif TOKEN_LISTS.include?(name)
          [name, value.split(/\s+/).reject(&:empty?).join(" ")]
        else
          [name, value]
        end
      end

      def attribute_name(attribute)
        prefix = attribute.namespace&.prefix
        prefix ? "#{prefix}:#{attribute.name}" : attribute.name
      end

      def collapse(text)
        text.gsub(/\s+/, " ").strip
      end

      def escape_text(text)
        text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      # Newlines, tabs and carriage returns inside an attribute value survive
      # parsing, but writing them literally would break the one-node-per-line
      # layout (and a browser rewrites a literal CR). Character references round
      # trip through the parser unchanged and keep the file line-oriented.
      def escape_attribute(value)
        escape_text(value)
          .gsub('"', "&quot;")
          .gsub("\r", "&#13;")
          .gsub("\n", "&#10;")
          .gsub("\t", "&#9;")
      end
    end
  end
end
