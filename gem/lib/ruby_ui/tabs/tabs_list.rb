# frozen_string_literal: true

module RubyUI
  # Base UI's Tabs.List (role=tablist). variant: :default (muted pill) or
  # :line (underline on the active tab). activate_on_focus: true activates a
  # tab as the arrow keys reach it (default: Enter/Space or click activate).
  # loop_focus: false stops the arrow keys at the first and last tab.
  class TabsList < Base
    VARIANTS = %i[default line].freeze

    def initialize(variant: :default, activate_on_focus: false, loop_focus: true, **attrs)
      @variant = VARIANTS.include?(variant.to_s.to_sym) ? variant.to_s.to_sym : :default
      @activate_on_focus = activate_on_focus
      @loop_focus = loop_focus
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "tablist",
        data: {
          slot: "tabs-list",
          variant: @variant,
          activate_on_focus: (@activate_on_focus ? "true" : nil),
          loop_focus: (@loop_focus ? nil : "false"),
          ruby_ui__tabs_target: "list",
          action: "keydown->ruby-ui--tabs#keydown focusout->ruby-ui--tabs#listFocusout"
        },
        class: [
          "group/tabs-list inline-flex w-fit items-center justify-center p-[3px] text-muted-foreground",
          # Bare h-9, so a caller's h-* replaces it; vertical lists size to content.
          "h-9 group-data-[orientation=vertical]/tabs:h-fit group-data-[orientation=vertical]/tabs:flex-col",
          (@variant == :line) ? "gap-1 rounded-none bg-transparent" : "rounded-lg bg-muted"
        ]
      }
    end
  end
end
