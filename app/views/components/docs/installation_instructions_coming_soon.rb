# frozen_string_literal: true

class Docs::InstallationInstructionsComingSoon < ApplicationComponent
    def initialize(title: 'Installation', description: 'Everything you need to know to get started with this component.')
        @title = title
        @description = description  
    end

    def template(&)
        render_header if @title || @description
    end

    def render_header
        div() do
            div(class: 'space-y-1 mb-4') do
                render Typography::H4.new { @title } if @title
                render Typography::P.new { @description } if @description
            end
            div(class: 'ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
                div(class: 'preview flex min-h-[350px] w-full justify-center p-10 items-center') do
                    render Typography::P.new(class: 'text-muted-foreground') { "Coming soon..." }
                end
            end
        end
    end
end
