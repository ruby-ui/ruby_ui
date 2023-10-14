# frozen_string_literal: true

class DialogFooter < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 gap-y-2 sm:gap-y-0", @attributes[:class]), &)
    end
end