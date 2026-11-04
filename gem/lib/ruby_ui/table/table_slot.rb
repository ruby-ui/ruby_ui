# frozen_string_literal: true

module RubyUI
  # shadcn spreads props after data-slot, so a caller's slot replaces a Table
  # part's default instead of Base#mix joining both values (as in Input).
  module TableSlot
    SLOT_ATTRS = [:data_slot, :"data-slot", "data-slot", "data_slot"].freeze
    SLOT_KEYS = [:slot, :slot!, "slot", "slot!"].freeze

    def initialize(**attrs)
      @caller_slot = caller_slot?(attrs)
      super
    end

    private

    def caller_slot?(attrs)
      return true if attrs.key?(:data!) || SLOT_ATTRS.any? { |key| attrs.key?(key) }

      data = attrs[:data] || attrs["data"]
      data.is_a?(Hash) && SLOT_KEYS.any? { |key| data.key?(key) }
    end

    # The part's own slot, or nil when the caller passed one.
    def default_slot(name)
      @caller_slot ? nil : name
    end
  end
end
