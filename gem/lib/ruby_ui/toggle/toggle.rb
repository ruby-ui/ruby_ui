# frozen_string_literal: true

module RubyUI
  class Toggle < Base
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

    def initialize(
      pressed: false,
      name: nil,
      value: "1",
      unpressed_value: nil,
      variant: :default,
      size: :default,
      disabled: false,
      **attrs
    )
      @pressed = pressed
      @name = name
      @value = value
      @unpressed_value = unpressed_value
      @variant = variant.to_sym
      @size = size.to_sym
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&block)
      render_button(&block)
      render_hidden_input if @name
    end

    private

    def render_button(&block)
      button(**attrs, &block)
    end

    def render_hidden_input
      input(
        type: "hidden",
        name: @name,
        value: @pressed ? @value : @unpressed_value.to_s,
        data: {"ruby-ui--toggle-target": "input"}
      )
    end

    def default_attrs
      base = {
        type: "button"
      }
      base[:disabled] = true if @disabled
      base.merge(
        aria: {pressed: @pressed.to_s},
        data: {
          state: @pressed ? "on" : "off",
          controller: "ruby-ui--toggle",
          action: "click->ruby-ui--toggle#toggle",
          "ruby-ui--toggle-pressed-value": @pressed.to_s,
          "ruby-ui--toggle-value-value": @value.to_s,
          "ruby-ui--toggle-unpressed-value-value": @unpressed_value.to_s
        },
        class: classes
      )
    end

    def classes
      [BASE_CLASSES, variant_classes, size_classes]
    end

    def variant_classes
      case @variant
      when :outline
        "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
      else
        "bg-transparent"
      end
    end

    def size_classes
      case @size
      when :sm then "h-8 min-w-8 px-1.5"
      when :lg then "h-10 min-w-10 px-2.5"
      else "h-9 min-w-9 px-2"
      end
    end
  end
end
