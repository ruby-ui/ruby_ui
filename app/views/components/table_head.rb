# frozen_string_literal: true

class TableHead < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        th(**@attributes, class: tokens("h-10  px-2  text-left align-middle font-medium text-muted-foreground[& amp; :has([ role= checkbox])] :pr-0 [& amp;>[role=checkbox]]:translate-y-[2px]", @attributes[:class]), &)
    end
end