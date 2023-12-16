# frozen_string_literal: true

class Shared::Container < ApplicationComponent
    DEFAULT_CLASS = 'container mx-auto w-full px-4'
    SIZE_CLASSES = {
        'sm': 'max-w-md',
        'md': 'max-w-2xl',
        'lg': 'max-w-4xl',
        'xl': 'max-w-6xl',
        '2xl': 'max-w-7xl',
    }

    def initialize(size: 'md', **attrs)
        @attrs = attrs
        @attrs[:class] = tokens(DEFAULT_CLASS, SIZE_CLASSES[size].to_s, @attrs[:class])
    end

    def template(&)
        div(**@attrs, &)
    end
end