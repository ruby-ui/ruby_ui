# frozen_string_literal: true

class Button < ApplicationComponent
    def initialize(variant: :primary, size: nil)
        @variant = variant
        @size = size
    end

    def template(&)
        case @variant
        when :primary
            button(class: tokens("inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-9", -> { @size == "icon" } => "h-9 w-9", -> { @size.nil? } => "px-4 py-2"), &)
        when :link
            button(class: "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 text-primary underline-offset-4 hover:underline h-9 px-4 py-2", &)
        when :secondary
            button(class: tokens("inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80 h-9", -> { @size == "icon" } => "h-9 w-9", -> { @size.nil? } => "px-4 py-2"), &)
        when :destructive
            button(class: tokens("inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90 h-9", -> { @size == "icon" } => "h-9 w-9", -> { @size.nil? } => "px-4 py-2"), &)
        when :outline
            button(class: tokens("inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-transparent shadow-sm hover:bg-accent hover:text-accent-foreground h-9", -> { @size == "icon" } => "h-9 w-9", -> { @size.nil? } => "px-4 py-2"), &)
        when :ghost
            button(class: tokens("inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-9", -> { @size == "icon" } => "h-9 w-9", -> { @size.nil? } => "px-4 py-2"), &)
        end
    end
end