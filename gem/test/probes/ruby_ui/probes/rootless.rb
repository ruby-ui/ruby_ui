# frozen_string_literal: true

module RubyUI
  module Probes
    # Renders no root element at all when hidden — DataTablePagination's shape.
    class Rootless < Component
      def initialize(shown: true, **attrs)
        @shown = shown
        super(**attrs)
      end

      def shown? = @shown
    end
  end
end
