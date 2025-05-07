# frozen_string_literal: true

module RubyUI
  class Button < Base
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

    def primary_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors bg-primary text-primary-foreground shadow",
        "hover:bg-primary/90",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def link_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors text-primary underline-offset-4",
        "hover:underline",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def secondary_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors bg-secondary text-secondary-foreground",
        "hover:bg-opacity-80",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def destructive_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors bg-destructive text-destructive-foreground shadow-sm",
        "hover:bg-destructive/90",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def outline_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors border border-input bg-background shadow-sm",
        "hover:bg-accent hover:text-accent-foreground",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def ghost_classes
      [
        "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors",
        "hover:bg-accent hover:text-accent-foreground",
        "disabled:pointer-events-none disabled:opacity-50",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring",
        "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
        size_classes
      ]
    end

    def default_classes
      case @variant
      when :primary then primary_classes
      when :link then link_classes
      when :secondary then secondary_classes
      when :destructive then destructive_classes
      when :outline then outline_classes
      when :ghost then ghost_classes
      end
    end

    def default_attrs
      {
        type: @type,
        class: default_classes
      }
    end
  end
end
