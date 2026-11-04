# frozen_string_literal: true

module RubyUI
  # Root of the tooltip: scopes the trigger and the content for the Stimulus
  # controller. open: renders it open on load (Base UI's defaultOpen) and
  # disabled: keeps it from opening (Base UI's Root disabled). Setting the
  # data-ruby-ui--tooltip-open-value or -disabled-value attribute later
  # opens, closes or disables it; every change dispatches
  # ruby-ui--tooltip:change with detail {open:}.
  #
  # placement: is the older API: TooltipContent's side: wins over it.
  class Tooltip < Base
    def initialize(placement: nil, open: false, disabled: false, **attrs)
      @placement = placement
      @open = open
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "tooltip",
          controller: "ruby-ui--tooltip",
          ruby_ui__tooltip_placement_value: @placement&.to_s,
          ruby_ui__tooltip_open_value: @open.to_s,
          ruby_ui__tooltip_disabled_value: @disabled.to_s
        },
        class: "group"
      }
    end
  end
end
