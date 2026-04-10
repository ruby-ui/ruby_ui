# frozen_string_literal: true

module RubyUI
  module Generators
    # Transforms a plain Ruby ComponentBase class into a Phlex class.
    #
    # Takes the source of a component.rb (which uses include ComponentBase)
    # and a view_template body string (from HerbToPhlexVisitor), and produces
    # a valid Phlex class that extends RubyUI::Base.
    #
    # The transformation:
    #   - class X\n  include ComponentBase  →  class X < Base
    #   - Removes include ComponentBase lines
    #   - Removes attr_reader :attrs / def attrs (Base provides it)
    #   - Removes def deep_merge (Base provides it as deep_merge_attrs)
    #   - Inserts def view_template before the private section
    module PhlexTransformer
      module_function

      def transform(plain_source, view_template_body)
        result = plain_source.dup

        # 1. Fold "class X ⏎  include ComponentBase" into "class X < Base"
        result.sub!(/class (\w+)\n(\s*)include ComponentBase/) do
          "class #{$1} < Base"
        end

        # 2. Remove any remaining bare include ComponentBase
        result.gsub!(/^\s*include ComponentBase\s*\n/, "")

        # 3. Remove attr_reader :attrs (Base provides it)
        result.gsub!(/^\s*attr_reader :attrs\s*\n/, "")

        # 4. Remove one-liner def attrs = @attrs
        result.gsub!(/^\s*def attrs\s*=\s*@attrs\s*\n/, "")

        # 5. Remove multi-line def attrs block
        result.gsub!(/^\s*def attrs\n\s*@attrs\s*\n\s*end\s*\n/m, "")

        # 6. Remove deep_merge helper (Base has deep_merge_attrs)
        result.gsub!(/\n\s*def deep_merge\b.*?end\s*\n/m, "\n")

        # 7. Insert view_template before "private" keyword (any indent level)
        if (m = result.match(/^(\s+)private\b/))
          pad = m[1]
          view_method = build_view_method(view_template_body, indent: pad)
          result.sub!(/^#{Regexp.escape(pad)}private\b/, "#{view_method}\n\n#{pad}private")
        else
          # Fallback: insert before the last closing end
          view_method = build_view_method(view_template_body, indent: "    ")
          result.sub!(/\nend\z/, "\n\n#{view_method}\nend")
        end

        result
      end

      def build_view_method(body, indent: "    ")
        inner = body.strip.lines.map { |l| "#{indent}  #{l}" }.join.rstrip
        "#{indent}def view_template(&)\n#{inner}\n#{indent}end"
      end
    end
  end
end
