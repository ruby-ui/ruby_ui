# frozen_string_literal: true

require_relative "herb_to_phlex_visitor"

module RubyUI
  module Herb
    # Generates a complete Phlex component class from:
    # 1. A Herb template (.html.erb / .html.herb) — the HTML structure
    # 2. A plain Ruby class (button_herb.rb) — the component logic
    #
    # Usage:
    #   code = PhlexGenerator.generate_view_template("lib/ruby_ui/button/button.html.herb")
    #   # => "button(type: html_attrs[:type], class: html_attrs[:class], &)"
    #
    #   full = PhlexGenerator.generate_class(
    #     template_path: "lib/ruby_ui/button/button.html.herb",
    #     class_name: "Button",
    #     module_name: "RubyUI",
    #     base_class: "Base"
    #   )
    #   # => Full Phlex class source code
    module PhlexGenerator
      module_function

      # Parse a Herb template and return just the view_template body.
      def generate_view_template(template_source)
        result = ::Herb.parse(template_source)

        unless result.success?
          errors = result.errors.map(&:to_s).join(", ")
          raise ArgumentError, "Herb parse failed: #{errors}"
        end

        visitor = HerbToPhlexVisitor.new
        result.visit(visitor)
        visitor.to_phlex
      end

      # Parse a Herb template file and return just the view_template body.
      def generate_view_template_from_file(template_path)
        source = File.read(template_path)
        generate_view_template(source)
      end

      # Generate a complete Phlex class with view_template method.
      def generate_class(template_source:, class_name:, module_name: "RubyUI", base_class: "Base")
        body = generate_view_template(template_source)

        indented_body = body.lines.map { |l| "      #{l}" }.join
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            class #{class_name} < #{base_class}
              def view_template(&)
          #{indented_body.rstrip}
              end
            end
          end
        RUBY
      end
    end
  end
end
