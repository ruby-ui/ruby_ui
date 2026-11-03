# frozen_string_literal: true

module RubyUI
  # One choice of a DropdownMenuRadioGroup (role menuitemradio). Activating it
  # checks it, unchecks its siblings, keeps the menu open and fires
  # ruby-ui--dropdown-menu:change with {checked, value} in the detail.
  class DropdownMenuRadioItem < Base
    ITEM = [
      "group/dropdown-menu-radio-item relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none",
      "focus:bg-accent focus:text-accent-foreground focus:**:text-accent-foreground",
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
        render DropdownMenuItemIndicator.new(kind: :radio)
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
          slot: "dropdown-menu-radio-item",
          value: @value,
          inset: @inset,
          disabled: @disabled,
          action: "click->ruby-ui--dropdown-menu#activate pointermove->ruby-ui--dropdown-menu#hover pointerleave->ruby-ui--dropdown-menu#leave"
        },
        class: ITEM
      }
    end
  end
end
