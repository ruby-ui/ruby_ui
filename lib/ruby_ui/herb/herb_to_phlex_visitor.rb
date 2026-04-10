# frozen_string_literal: true

require "herb"

module RubyUI
  module Herb
    # Walks a Herb AST (parsed from an .html.erb/.html.herb template) and
    # generates the body of a Phlex `view_template` method.
    #
    # Usage:
    #   result  = ::Herb.parse(template_source)
    #   visitor = HerbToPhlexVisitor.new
    #   result.visit(visitor)
    #   visitor.to_phlex  # => "button(**attrs, &)\n"
    class HerbToPhlexVisitor < ::Herb::Visitor
      attr_reader :output

      def initialize
        super
        @output = +""
        @indent = 0
      end

      def visit_child_nodes(node)
        case node
        when ::Herb::AST::DocumentNode
          super
        when ::Herb::AST::HTMLElementNode
          visit_element(node)
        when ::Herb::AST::HTMLTextNode
          visit_text(node)
        when ::Herb::AST::ERBContentNode
          visit_erb_content(node)
        when ::Herb::AST::ERBIfNode
          visit_erb_if(node)
        when ::Herb::AST::ERBUnlessNode
          visit_erb_unless(node)
        when ::Herb::AST::ERBBlockNode
          visit_erb_block(node)
        when ::Herb::AST::ERBCaseNode
          visit_erb_case(node)
        when ::Herb::AST::ERBForNode
          visit_erb_for(node)
        when ::Herb::AST::ERBYieldNode
          visit_erb_yield(node)
        when ::Herb::AST::HTMLCommentNode
          visit_html_comment(node)
        else
          # For nodes we don't handle specially (open/close tags, attribute
          # nodes, etc.), just recurse into children.
          super
        end
      end

      # Returns the generated Phlex code string.
      def to_phlex
        @output.strip
      end

      private

      # ── HTML Element ──────────────────────────────────────────────

      def visit_element(node)
        tag = token_value(node.tag_name)
        attrs = collect_attributes(node.open_tag)
        children = meaningful_body_nodes(node)

        phlex_tag = phlex_method_name(tag)

        if children.empty? && node.is_void
          # Self-closing / void element: e.g. input, br, hr
          emit_line("#{phlex_tag}(#{attrs})") unless attrs.empty?
          emit_line(phlex_tag) if attrs.empty?
        elsif children.empty?
          emit_line("#{phlex_tag}(#{attrs})") unless attrs.empty?
          emit_line(phlex_tag) if attrs.empty?
        else
          args = attrs.empty? ? "" : "(#{attrs})"

          # Check if the only meaningful child is a yield — use &block form
          if children.size == 1 && yield_node?(children.first)
            # If attrs is already a splat (**expr), append , & cleanly
            block_args = if attrs.empty?
              "(&)"
            elsif attrs.start_with?("**")
              "(#{attrs}, &)"
            else
              "(#{attrs}, &)"
            end
            emit_line("#{phlex_tag}#{block_args}")
          else
            emit_line("#{phlex_tag}#{args} do")
            indent { visit_body_children(children) }
            emit_line("end")
          end
        end
      end

      # ── HTML Text ─────────────────────────────────────────────────

      def visit_text(node)
        text = extract_text_content(node).strip
        return if text.empty?

        emit_line("plain \"#{escape_string(text)}\"")
      end

      # ── ERB Tags ──────────────────────────────────────────────────

      def visit_erb_content(node)
        tag_opening = token_value(node.tag_opening).strip
        content = extract_erb_body(node).strip
        return if content.empty?

        if tag_opening == "<%="
          # Output tag — emit the Ruby expression
          if content == "yield"
            emit_line("yield")
          else
            emit_line(content)
          end
        elsif tag_opening == "<%#"
          # Comment tag — emit as Ruby comment
          emit_line("# #{content}")
        else
          # Execution tag (<%) — emit as Ruby code
          emit_line(content)
        end
      end

      def visit_erb_yield(node)
        emit_line("yield")
      end

      def visit_erb_if(node)
        # ERBIfNode content already includes the "if" keyword
        emit_line(extract_erb_body(node).strip)
        indent { traverse_children(node) }
        emit_line("end")
      end

      def visit_erb_unless(node)
        # ERBUnlessNode content already includes "unless"
        emit_line(extract_erb_body(node).strip)
        indent { traverse_children(node) }
        emit_line("end")
      end

      def visit_erb_block(node)
        emit_line(extract_erb_body(node).strip)
        indent { traverse_children(node) }
        emit_line("end")
      end

      def visit_erb_case(node)
        # ERBCaseNode content already includes "case"
        emit_line(extract_erb_body(node).strip)
        indent { traverse_children(node) }
        emit_line("end")
      end

      def visit_erb_for(node)
        emit_line(extract_erb_body(node).strip)
        indent { traverse_children(node) }
        emit_line("end")
      end

      # ── HTML Comment ──────────────────────────────────────────────

      def visit_html_comment(node)
        emit_line("comment { \"#{escape_string(extract_text_content(node).strip)}\" }")
      end

      # ── Attribute Collection ──────────────────────────────────────

      def collect_attributes(open_tag)
        return "" unless open_tag.respond_to?(:children)

        parts = open_tag.children.flat_map do |child|
          if child.is_a?(::Herb::AST::HTMLAttributeNode)
            [format_attribute(child)]
          elsif child.is_a?(::Herb::AST::ERBContentNode)
            # ERBContentNode directly in open tag = splat attrs expression
            # tag_attributes(expr) → **expr   |   raw_expr → **raw_expr
            [splat_attr(extract_erb_body(child).strip)]
          else
            []
          end
        end.compact

        parts.join(", ")
      end

      # Convert a tag-position ERB expression to a Phlex splat.
      # tag_attributes(attrs) → **attrs
      # any_expr             → **any_expr
      def splat_attr(content)
        inner = content.match(/\Atag_attributes\((.+)\)\z/)&.captures&.first || content
        "**#{inner}"
      end

      def format_attribute(attr)
        name = extract_attribute_name(attr)
        value = extract_attribute_value(attr)

        return nil if name.nil? || name.empty?

        # Boolean attribute (no value)
        if value.nil?
          return "#{phlex_attr_name(name)}: true"
        end

        "#{phlex_attr_name(name)}: #{value}"
      end

      def extract_attribute_name(attr)
        name_node = attr.name

        if name_node.respond_to?(:children)
          # HTMLAttributeNameNode has children (LiteralNode with string content)
          name_node.children.map { |c| extract_node_text(c) }.join.strip
        elsif name_node.respond_to?(:content)
          token_value(name_node.content).strip
        else
          token_value(name_node).strip
        end
      end

      def extract_attribute_value(attr)
        return nil unless attr.respond_to?(:value) && attr.value

        val_node = attr.value

        if val_node.respond_to?(:children)
          children = val_node.children.to_a

          # Pure ERB expression: class="<%= expr %>"
          erb_children = children.select { |c| c.is_a?(::Herb::AST::ERBContentNode) }
          literal_children = children.reject { |c| c.is_a?(::Herb::AST::ERBContentNode) || whitespace_only?(c) }

          if erb_children.size == 1 && literal_children.empty?
            # Single ERB expression — emit as bare Ruby
            return extract_erb_body(erb_children.first).strip
          end

          if erb_children.empty?
            # Pure static string
            text = children.map { |c| extract_node_text(c) }.join
            return "\"#{escape_string(text)}\""
          end

          # Mixed static + ERB: build a string interpolation
          parts = children.map do |c|
            if c.is_a?(::Herb::AST::ERBContentNode)
              "\#{#{extract_erb_body(c).strip}}"
            else
              escape_string(extract_node_text(c))
            end
          end
          "\"#{parts.join}\""
        else
          "\"#{escape_string(val_node.to_s.strip)}\""
        end
      end

      # ── Name Conversion ───────────────────────────────────────────

      # Convert HTML attribute name to Phlex keyword argument style.
      # "data-action" → "data_action:"  but we return just the key part.
      def phlex_attr_name(name)
        # Phlex supports both symbol-style and string-style attrs.
        # For data-* and aria-*, Phlex accepts underscored symbols.
        name.tr("-", "_")
      end

      # Convert HTML tag name to Phlex method name.
      # Most are identity (div, span, button). Some need special handling.
      PHLEX_TAG_MAP = {
        "template_tag" => "template_tag"
      }.freeze

      def phlex_method_name(tag)
        PHLEX_TAG_MAP.fetch(tag, tag)
      end

      # ── Helpers ───────────────────────────────────────────────────

      # Traverse the actual children of a node without going through our dispatch.
      # Used by ERB control-flow visitors so they don't re-dispatch on themselves.
      def traverse_children(node)
        node.compact_child_nodes.each { |child| child.accept(self) }
      end

      # Extract the string value from a Herb::Token or plain string.
      def token_value(token_or_string)
        if token_or_string.respond_to?(:value)
          token_or_string.value.to_s
        else
          token_or_string.to_s
        end
      end

      def meaningful_body_nodes(element)
        return [] unless element.respond_to?(:body)
        body = element.body
        return [] if body.nil?

        nodes = if body.respond_to?(:compact_child_nodes)
          body.compact_child_nodes
        elsif body.respond_to?(:children)
          body.children
        elsif body.is_a?(Array)
          body
        else
          [body]
        end

        nodes.reject { |n| whitespace_only?(n) }
      end

      def visit_body_children(children)
        children.each { |child| child.accept(self) }
      end

      def yield_node?(node)
        return true if node.is_a?(::Herb::AST::ERBYieldNode)
        if node.is_a?(::Herb::AST::ERBContentNode)
          body = extract_erb_body(node).strip
          return body == "yield" || body.start_with?("yield")
        end
        false
      end

      def extract_node_text(node)
        if node.respond_to?(:content)
          content = node.content
          content.respond_to?(:value) ? content.value.to_s : content.to_s
        elsif node.respond_to?(:children)
          node.children.map { |c| extract_node_text(c) }.join
        else
          node.to_s
        end
      end

      def extract_erb_body(node)
        if node.respond_to?(:content)
          content = node.content
          content.respond_to?(:value) ? content.value.to_s : content.to_s
        else
          node.to_s
        end
      end

      def extract_text_content(node)
        extract_node_text(node)
      end

      def whitespace_only?(node)
        return true if node.is_a?(::Herb::AST::WhitespaceNode)
        if node.respond_to?(:content)
          text = extract_node_text(node)
          return text.strip.empty?
        end
        false
      end

      def escape_string(str)
        str.gsub("\\", "\\\\\\\\").gsub('"', '\\"')
      end

      def emit_line(code)
        @output << ("  " * @indent) << code << "\n"
      end

      def indent
        @indent += 1
        yield
      ensure
        @indent -= 1
      end
    end
  end
end
