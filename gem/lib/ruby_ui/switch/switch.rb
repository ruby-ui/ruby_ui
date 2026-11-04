# frozen_string_literal: true

module RubyUI
  # A switch, styled after shadcn's Switch (Base UI + vega). Renders a native
  # <input type="checkbox" role="switch"> instead of Base UI's span[role=switch]
  # plus hidden input: the input itself is the track (appearance-none) and its
  # ::before is the thumb, so it is focusable, toggles with Space, is named by
  # a <label for> and exposes its checked state with no JavaScript. ::after
  # widens the hit area like shadcn, and peer-* classes on a following label
  # keep working.
  #
  # size: :default (18.4x32px) or :sm (14x24px), as shadcn's size prop.
  # include_hidden: renders a hidden input with the same name and
  # unchecked_value before the switch, so the form also sends a value when it
  # is off (Rails' check_box pattern). checked_value is the switch's value.
  class Switch < Base
    SIZES = %i[default sm].freeze

    BASE = [
      "peer relative inline-flex shrink-0 appearance-none rounded-full border border-transparent p-0 align-middle",
      "data-[size=default]:h-[18.4px] data-[size=default]:w-[32px] data-[size=sm]:h-[14px] data-[size=sm]:w-[24px]",
      # High contrast: give the drawing back to the browser (as @tailwindcss/forms does).
      "forced-colors:appearance-auto forced-colors:before:hidden",
      "bg-input dark:bg-input/80 checked:bg-primary dark:checked:bg-primary checked:bg-none",
      "text-inherit shadow-xs transition-all outline-none",
      "after:absolute after:-inset-x-3 after:-inset-y-2",
      "focus:ring-0 focus:ring-offset-0 focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
      "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
      "dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40",
      "disabled:cursor-not-allowed disabled:opacity-50",
      "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none",
      # Thumb.
      "before:pointer-events-none before:absolute before:inset-y-0 before:left-0 before:my-auto before:block before:rounded-full",
      "before:bg-background dark:before:bg-foreground dark:checked:before:bg-primary-foreground",
      "before:transition-transform before:translate-x-0 checked:before:translate-x-[calc(100%-2px)]",
      "data-[size=default]:before:size-4 data-[size=sm]:before:size-3"
    ].freeze

    def initialize(size: :default, include_hidden: true, checked_value: "1", unchecked_value: "0", **attrs)
      @size = size.to_sym
      raise ArgumentError, "size: must be one of #{SIZES.join(", ")}" unless SIZES.include?(@size)

      @include_hidden = include_hidden
      @checked_value = checked_value
      @unchecked_value = unchecked_value
      super(**attrs)
    end

    def view_template
      if @include_hidden
        input(type: "hidden", name: attrs[:name], value: @unchecked_value, disabled: attrs[:disabled], form: attrs[:form], autocomplete: "off")
      end
      input(**attrs, value: @checked_value)
    end

    private

    def default_attrs
      {
        type: "checkbox",
        role: "switch",
        data: {slot: "switch", size: @size},
        class: BASE
      }
    end
  end
end
