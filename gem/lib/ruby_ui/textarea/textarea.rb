# frozen_string_literal: true

module RubyUI
  class Textarea < Base
    def initialize(rows: 4, **attrs)
      @rows = rows
      super(**attrs)
    end

    def view_template(&)
      textarea(rows: @rows, **attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__form_field_target: "input",
          action: "input->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"
        },
        class: [
          "flex w-full rounded-md border bg-background px-3 py-1 text-sm shadow-sm transition-colors border-border",
          "placeholder:text-muted-foreground",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "file:border-0 file:bg-transparent file:text-sm file:font-medium",
          "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none"
        ]
      }
    end
  end
end
