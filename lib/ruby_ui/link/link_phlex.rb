# frozen_string_literal: true

module RubyUI
  class Link < Base
    BASE_CLASSES = [
      "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors",
      "disabled:pointer-events-none disabled:opacity-50",
      "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
      "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed"
    ].freeze

    def initialize(href: "#", variant: :link, size: :md, icon: false, **attrs)
      @href = href
      @variant = variant.to_sym
      @size = size.to_sym
      @icon = icon
      super(**attrs)
    end

    def view_template(&)
      a(**attrs, &)
    end

    private

    def size_classes
      if @icon
        case @size
        when :sm then "h-6 w-6"
        when :md then "h-9 w-9"
        when :lg then "h-10 w-10"
        when :xl then "h-12 w-12"
        end
      else
        case @size
        when :sm then "px-3 py-1.5 h-8 text-xs"
        when :md then "px-4 py-2 h-9 text-sm"
        when :lg then "px-4 py-2 h-10 text-base"
        when :xl then "px-6 py-3 h-12 text-base"
        end
      end
    end

    def variant_classes
      case @variant
      when :primary
        ["bg-primary text-primary-foreground shadow", "hover:bg-primary/90"]
      when :link
        ["text-primary underline-offset-4", "hover:underline"]
      when :secondary
        ["bg-secondary text-secondary-foreground", "hover:bg-opacity-80"]
      when :destructive
        ["bg-destructive text-white shadow-sm", "[a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20", "dark:focus-visible:ring-destructive/40 dark:bg-destructive/60"]
      when :outline
        ["border border-input bg-background shadow-sm", "hover:bg-accent hover:text-accent-foreground"]
      when :ghost
        ["hover:bg-accent hover:text-accent-foreground"]
      end
    end

    def default_attrs
      {href: @href, class: [BASE_CLASSES, size_classes, variant_classes]}
    end
  end
end
