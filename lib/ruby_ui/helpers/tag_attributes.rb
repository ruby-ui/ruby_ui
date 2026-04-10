# frozen_string_literal: true

require "cgi"

module RubyUI
  module Helpers
    # Converts a Ruby attribute hash to an HTML-safe attribute string.
    # Handles nested hashes (data-*, aria-*), boolean attrs, arrays, and nil.
    #
    # Usage in templates:
    #   <div <%= tag_attributes(attrs) %>>...</div>
    #
    # Usage in tests:
    #   include RubyUI::Helpers::TagAttributes
    #   tag_attributes({ class: "foo", data: { controller: "bar" } })
    #   # => 'class="foo" data-controller="bar"'
    module TagAttributes
      module_function

      def tag_attributes(attrs)
        return "" if attrs.nil? || attrs.empty?

        build_pairs(attrs).join(" ")
      end

      def build_pairs(attrs, prefix = nil)
        attrs.flat_map do |key, value|
          next [] if value.nil? || value == false

          name = [prefix, key.to_s.tr("_", "-")].compact.join("-")

          case value
          when Hash then build_pairs(value, name)
          when true then [name]
          when Array then ["#{name}=\"#{escape(value.flatten.compact.join(" "))}\""]
          else ["#{name}=\"#{escape(value)}\""]
          end
        end
      end

      def escape(value)
        CGI.escapeHTML(value.to_s)
      end
    end
  end
end
