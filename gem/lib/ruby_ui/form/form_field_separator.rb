# frozen_string_literal: true

module RubyUI
  class FormFieldSeparator < Base
    def view_template(&block)
      div(**mix(attrs, data: {content: block ? "true" : "false"})) do
        render RubyUI::Separator.new(decorative: false, class: "absolute inset-0 top-1/2")
        if block
          span(
            data: {slot: "field-separator-content"},
            class: "relative mx-auto block w-fit bg-background px-2 text-muted-foreground",
            &block
          )
        end
      end
    end

    private

    def default_attrs
      {
        data: {slot: "field-separator"},
        class: "relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2"
      }
    end
  end
end
