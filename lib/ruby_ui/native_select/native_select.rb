# frozen_string_literal: true

module RubyUI
  class NativeSelect < Base
    def initialize(size: :default, **attrs)
      @size = size
      super(**attrs)
    end

    def view_template(&block)
      div(
        class: "group/native-select relative w-fit has-[select:disabled]:opacity-50"
      ) do
        select(**attrs, &block)
        chevron_icon
      end
    end

    private

    def chevron_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "text-muted-foreground pointer-events-none absolute top-1/2 right-2.5 size-4 -translate-y-1/2 select-none",
        aria_hidden: "true"
      ) do |s|
        s.path(d: "m6 9 6 6 6-6")
      end
    end

    def default_attrs
      {
        data: {
          ruby_ui__form_field_target: "input",
          action: "change->ruby-ui--form-field#onChange invalid->ruby-ui--form-field#onInvalid"
        },
        class: [
          "border-border bg-transparent text-sm w-full min-w-0 appearance-none rounded-md border py-1 pr-8 pl-2.5 shadow-xs transition-[color,box-shadow] outline-none select-none ring-0 ring-ring/0",
          "placeholder:text-muted-foreground",
          "selection:bg-primary selection:text-primary-foreground",
          "focus-visible:outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-2",
          "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
          "aria-invalid:ring-destructive/20 aria-invalid:border-destructive aria-invalid:ring-2",
          @size == :sm ? "h-7 rounded-md py-0.5" : "h-9"
        ]
      }
    end
  end
end
