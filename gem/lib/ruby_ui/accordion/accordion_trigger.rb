# frozen_string_literal: true

module RubyUI
  # The <summary> of an AccordionItem. Wraps its content in a heading
  # (h3 by default) and appends the chevron (icon: false to render your own).
  class AccordionTrigger < Base
    LEVELS = (1..6)

    def initialize(level: 3, icon: true, **attrs)
      raise ArgumentError, "level must be 1..6, got #{level.inspect}" unless LEVELS.cover?(level)

      @level = level
      @icon = icon
      super(**attrs)
    end

    def view_template(&block)
      item = context[:ruby_ui_accordion_item] || {}
      trigger_attrs = item[:disabled] ? mix(attrs, aria: {disabled: "true"}, tabindex: "-1") : attrs

      summary(**trigger_attrs) do
        send(:"h#{@level}", &block)
        render AccordionIcon.new if @icon
      end
    end

    private

    def default_attrs
      {
        data: {slot: "accordion-trigger"},
        class: [
          "group/accordion-trigger relative flex flex-1 cursor-pointer list-none items-start justify-between",
          "rounded-md border border-transparent py-4 text-left text-sm font-medium transition-all outline-none",
          "hover:underline focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50 [&::-webkit-details-marker]:hidden"
        ].join(" ")
      }
    end
  end
end
