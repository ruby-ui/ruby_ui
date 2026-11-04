# frozen_string_literal: true

module RubyUI
  # Base UI's Tabs.Root. default_value: is the tab shown first (shadcn's
  # defaultValue); without it the first enabled tab is shown. default: is its
  # old name, kept as an alias. orientation: :horizontal or :vertical.
  #
  # The controller marks the active tab and panel, wires aria-controls /
  # aria-labelledby, and dispatches ruby-ui--tabs:change ({value,
  # previousValue}) when someone picks another tab. Setting
  # data-ruby-ui--tabs-active-value switches tabs from outside.
  class Tabs < Base
    ORIENTATIONS = %i[horizontal vertical].freeze

    def initialize(default_value: nil, default: nil, orientation: :horizontal, **attrs)
      @default_value = default_value.nil? ? default : default_value
      @orientation = ORIENTATIONS.include?(orientation.to_s.to_sym) ? orientation.to_s.to_sym : :horizontal
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "tabs",
          orientation: @orientation,
          controller: "ruby-ui--tabs",
          ruby_ui__tabs_active_value: @default_value,
          ruby_ui__tabs_orientation_value: @orientation
        },
        class: ["group/tabs flex gap-2", ("flex-col" if @orientation == :horizontal)]
      }
    end
  end
end
