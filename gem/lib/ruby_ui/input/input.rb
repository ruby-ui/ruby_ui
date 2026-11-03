# frozen_string_literal: true

module RubyUI
  class Input < Base
    def initialize(type: nil, **attrs)
      @type = type
      @caller_slot = caller_slot?(attrs)
      @disabled = attrs[:disabled] || attrs["disabled"]
      super(**attrs)
    end

    def view_template
      input(type: @type, **attrs)
    end

    private

    # A caller's slot replaces "input" (shadcn spreads props after data-slot),
    # so the default is left out instead of letting mix join both values.
    SLOT_ATTRS = [:data_slot, :"data-slot", "data-slot", "data_slot"].freeze
    SLOT_KEYS = [:slot, :slot!, "slot", "slot!"].freeze

    def caller_slot?(attrs)
      return true if attrs.key?(:data!) || SLOT_ATTRS.any? { |key| attrs.key?(key) }

      data = attrs[:data] || attrs["data"]
      data.is_a?(Hash) && SLOT_KEYS.any? { |key| data.key?(key) }
    end

    def default_attrs
      {
        data: {
          slot: (@caller_slot ? nil : "input"),
          # Base UI Input marks the disabled state for data-disabled: styling.
          disabled: (@disabled ? true : nil),
          ruby_ui__form_field_target: "input",
          action: "input->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"
        }.compact,
        class: [
          "h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-2.5 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none md:text-sm dark:bg-input/30",
          "placeholder:text-muted-foreground",
          "file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground",
          "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
          "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
          "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
        ]
      }
    end
  end
end
