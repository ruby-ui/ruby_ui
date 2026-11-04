# frozen_string_literal: true

module RubyUI
  class NativeSelect < Base
    WRAPPER_CLASS = "group/native-select relative w-fit has-[select:disabled]:opacity-50"

    # As in shadcn, class styles the wrapper <div>; every other attribute
    # goes to the <select>.
    def initialize(size: :default, **attrs)
      @size = size
      @wrapper_class = attrs.delete(:class) || attrs.delete("class")
      super(**attrs)
    end

    def view_template(&block)
      div(
        class: TAILWIND_MERGER.merge(mix({class: WRAPPER_CLASS}, {class: @wrapper_class})[:class]),
        data: {slot: "native-select-wrapper", size: @size}
      ) do
        select(**attrs, &block)
        render RubyUI::NativeSelectIcon.new
      end
    end

    private

    def default_attrs
      {
        data: {
          slot: "native-select",
          size: @size,
          ruby_ui__form_field_target: "input",
          action: "change->ruby-ui--form-field#onChange invalid->ruby-ui--form-field#onInvalid"
        },
        class: [
          "h-9 w-full min-w-0 appearance-none rounded-md border border-input bg-transparent py-1 pr-8 pl-2.5 text-sm shadow-xs transition-[color,box-shadow] outline-none select-none data-[size=sm]:h-8 dark:bg-input/30 dark:hover:bg-input/50",
          "placeholder:text-muted-foreground",
          "selection:bg-primary selection:text-primary-foreground",
          "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
          "disabled:pointer-events-none disabled:cursor-not-allowed",
          "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40"
        ]
      }
    end
  end
end
