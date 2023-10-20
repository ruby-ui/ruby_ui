# frozen_string_literal: true

class ShortcutKey < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&block)
        kbd(**default_attributes.merge(@attributes), &block)
    end

    private

    def default_attributes
        {
            class: "pointer-events-none inline-flex h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium text-muted-foreground opacity-100"
        }
    end
end
