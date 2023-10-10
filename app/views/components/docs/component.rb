# frozen_string_literal: true

class Docs::Component < ApplicationComponent
    def initialize(title: "Title", description: "Description")
        @title = title
        @description = description
    end

    def template(&)
        div do
            div(class: 'space-y-1 mb-4') do
                render Typography::H4.new { @title }
                render Typography::P.new { @description }
            end
            div(class: 'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
                div(class: 'preview flex min-h-[350px] w-full justify-center p-10 items-center', &)
            end
        end
    end
end