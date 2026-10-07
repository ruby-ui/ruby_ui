# frozen_string_literal: true

module RubyUI
  class DataTableExpandToggle < Component
    def initialize(controls:, expanded: false, label: "Toggle row details", **attrs)
      @controls = controls
      @expanded = expanded
      @label = label
      super(**attrs)
    end

    # 1.6 spread the caller's attributes after the button's own, so a caller's
    # key replaced the button's; `merge` keeps that order.
    def button_attrs
      Attributes.flat({
        type: "button",
        aria_expanded: @expanded.to_s,
        aria_controls: @controls,
        aria_label: @label,
        data: {action: "click->ruby-ui--data-table#toggleRowDetail"}
      }.merge(mixed_attrs))
    end

    private

    def default_attrs
      {
        class: "group inline-flex items-center justify-center h-8 w-8 rounded-md hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      }
    end
  end
end
