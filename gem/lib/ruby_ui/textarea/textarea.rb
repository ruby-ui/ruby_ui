# frozen_string_literal: true

module RubyUI
  class Textarea < Base
    # rows is optional: without it the textarea sizes to its content
    # (field-sizing-content, min-h-16), as shadcn does.
    def initialize(rows: nil, **attrs)
      @rows = rows
      @caller_slot = caller_slot?(attrs)
      super(**attrs)
    end

    def view_template(&)
      textarea(rows: @rows, **attrs, &)
    end

    private

    # A caller's slot replaces "textarea" (shadcn spreads props after
    # data-slot), so the default is left out instead of letting mix join both.
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
          slot: (@caller_slot ? nil : "textarea"),
          ruby_ui__form_field_target: "input",
          action: "input->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"
        }.compact,
        class: [
          "flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-2.5 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none md:text-sm dark:bg-input/30",
          "placeholder:text-muted-foreground",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
          "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
        ]
      }
    end
  end
end
