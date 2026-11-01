# frozen_string_literal: true

module RubyUI
  # A native <details>. Open/close, the single-open group (name) and
  # find-in-page come from the browser; the height animates on
  # ::details-content where supported.
  class AccordionItem < Base
    def initialize(open: false, disabled: nil, **attrs)
      @open = open
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&)
      group = context[:ruby_ui_accordion] || {}
      disabled = @disabled.nil? ? group[:disabled] : @disabled
      previous = context[:ruby_ui_accordion_item]
      context[:ruby_ui_accordion_item] = {disabled: disabled}

      item_attrs = attrs.dup
      item_attrs[:name] ||= group[:name] if group[:name]
      item_attrs[:open] = true if @open
      details(**item_attrs, &)
    ensure
      context[:ruby_ui_accordion_item] = previous
    end

    private

    def default_attrs
      {
        data: {slot: "accordion-item"},
        class: [
          "group/accordion-item not-last:border-b [interpolate-size:allow-keywords]",
          "details-content:h-0 details-content:overflow-hidden open:details-content:h-auto",
          "details-content:transition-[height,content-visibility] details-content:transition-discrete",
          "details-content:duration-200 details-content:ease-out"
        ].join(" ")
      }
    end
  end
end
