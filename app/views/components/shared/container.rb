# frozen_string_literal: true

class Shared::Container < ApplicationComponent
    DEFAULT_CLASS = 'container mx-auto w-full px-4 max-w-2xl'
    def initialize(**attrs)
        @attrs = attrs
    end

    def template(&)
        div(**@attrs, class: tokens(DEFAULT_CLASS, @attrs[:class]), &)
    end
end