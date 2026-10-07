# frozen_string_literal: true

module RubyUI
  class Toggle < Component
    BASE_CLASSES = [
      "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap",
      "transition-[color,box-shadow] outline-none",
      "hover:bg-muted hover:text-muted-foreground",
      "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50",
      "disabled:pointer-events-none disabled:opacity-50",
      "aria-invalid:border-destructive aria-invalid:ring-destructive/20",
      "data-[state=on]:bg-accent data-[state=on]:text-accent-foreground",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    VARIANT_CLASSES = {
      default: "bg-transparent",
      outline: "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
    }.freeze

    SIZE_CLASSES = {
      sm: "h-8 min-w-8 px-1.5",
      default: "h-9 min-w-9 px-2",
      lg: "h-10 min-w-10 px-2.5"
    }.freeze

    def self.classes_for(variant:, size:)
      [BASE_CLASSES, VARIANT_CLASSES.fetch(variant, VARIANT_CLASSES[:default]), SIZE_CLASSES.fetch(size, SIZE_CLASSES[:default])]
    end

    attr_reader :name

    def initialize(
      pressed: false,
      name: nil,
      value: "1",
      unpressed_value: nil,
      variant: :default,
      size: :default,
      disabled: false,
      wrapper: {},
      **attrs
    )
      @pressed = pressed
      @name = name
      @value = value
      @unpressed_value = unpressed_value
      @variant = enum(variant, VARIANT_CLASSES, default: :default)
      @size = enum(size, SIZE_CLASSES, default: :default)
      @disabled = disabled
      @wrapper = wrapper
      super(**attrs)
    end

    # The wrapper's attributes, mixed as 1.6 did — no Tailwind merge on them.
    def wrapper_attrs
      Attributes.flat(Attributes.mix(wrapper_default_attrs, @wrapper))
    end

    def hidden_input_attrs
      Attributes.flat(
        type: "hidden",
        name: @name,
        value: @pressed ? @value : @unpressed_value.to_s,
        data: {"ruby-ui--toggle-target": "input"}
      )
    end

    private

    def wrapper_default_attrs
      {
        class: "contents",
        data: {
          controller: "ruby-ui--toggle",
          action: "click->ruby-ui--toggle#toggle",
          "ruby-ui--toggle-pressed-value": @pressed.to_s,
          "ruby-ui--toggle-value-value": @value.to_s,
          "ruby-ui--toggle-unpressed-value-value": @unpressed_value.to_s
        }
      }
    end

    def default_attrs
      base = {type: "button"}
      base[:disabled] = true if @disabled
      base.merge(
        aria: {pressed: @pressed.to_s},
        data: {
          state: @pressed ? "on" : "off",
          "ruby-ui--toggle-target": "button"
        },
        class: self.class.classes_for(variant: @variant, size: @size)
      )
    end
  end
end
