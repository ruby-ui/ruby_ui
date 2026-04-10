# frozen_string_literal: true

module RubyUI
  class Button < Base
    BASE_CLASSES = [
      "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors",
      "disabled:pointer-events-none disabled:opacity-50",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed"
    ].freeze

    ICON_SIZES = {
      sm: "h-6 w-6",
      md: "h-9 w-9",
      lg: "h-10 w-10",
      xl: "h-12 w-12"
    }.freeze

    SIZES = {
      sm: "px-3 py-1.5 h-8 text-xs",
      md: "px-4 py-2 h-9 text-sm",
      lg: "px-4 py-2 h-10 text-base",
      xl: "px-6 py-3 h-12 text-base"
    }.freeze

    def initialize(type: :button, variant: :primary, size: :md, icon: false, **attrs)
      @type = type
      @variant = variant.to_sym
      @size = size.to_sym
      @icon = icon
      super(**attrs)
    end

    def view_template(&)
      button(**attrs, &)
    end

    private

    def default_attrs
      {type: @type, class: [BASE_CLASSES, size_classes, variant_classes]}
    end

    def size_classes
      @icon ? ICON_SIZES[@size] : SIZES[@size]
    end

    def variant_classes
      case @variant
      when :primary then ["bg-primary text-primary-foreground shadow", "hover:bg-primary/90"]
      when :secondary then ["bg-secondary text-secondary-foreground", "hover:bg-opacity-80"]
      when :destructive then ["bg-destructive text-white shadow-sm", "[a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20", "dark:focus-visible:ring-destructive/40 dark:bg-destructive/60"]
      when :outline then ["border border-input bg-background shadow-sm", "hover:bg-accent hover:text-accent-foreground"]
      when :ghost then ["hover:bg-accent hover:text-accent-foreground"]
      when :link then ["text-primary underline-offset-4", "hover:underline"]
      end
    end
  end
end
