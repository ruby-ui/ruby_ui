# frozen_string_literal: true

module RubyUI
  module Probes
    # Mints an id and cross-references it — SelectContent's shape.
    class WithId < Component
      attr_reader :id

      def initialize(**attrs)
        @id = "content#{SecureRandom.hex(4)}"
        super
      end
    end
  end
end
