# frozen_string_literal: true

module RubyUI
  # One choice of a ContextMenuRadioGroup (role menuitemradio). Activating it
  # checks it, unchecks its siblings, keeps the menu open and fires
  # ruby-ui--context-menu:change with {checked, value} in the detail.
  class ContextMenuRadioItem < Base
    ITEM = [
      "group/context-menu-radio-item relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none",
      "focus:bg-accent focus:text-accent-foreground",
      "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    def initialize(value: nil, checked: false, inset: false, disabled: false, **)
      @value = value
      @checked = checked
      @inset = inset
      @disabled = disabled
      super(**)
    end

    def view_template(&block)
      div(**attrs) do
        render ContextMenuItemIndicator.new(kind: :radio)
        yield if block
      end
    end

    private

    def default_attrs
      {
        role: "menuitemradio",
        tabindex: "-1",
        aria: {checked: @checked.to_s, disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "context-menu-radio-item",
          value: @value,
          inset: @inset,
          disabled: @disabled,
          action: "click->ruby-ui--context-menu#activate pointermove->ruby-ui--context-menu#hover pointerleave->ruby-ui--context-menu#leave"
        },
        class: ITEM
      }
    end
  end
end
