# frozen_string_literal: true

module RubyUI
  module Probes
    # Content or a placeholder — SelectValue's shape.
    class Fallback < Component
      attr_reader :placeholder

      def initialize(placeholder:, **attrs)
        @placeholder = placeholder
        super(**attrs)
      end
    end
  end
end
