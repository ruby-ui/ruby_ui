# frozen_string_literal: true

class Docs::VisualCodeExample < ApplicationComponent
    def initialize(title: nil, description: nil)
        @title = title
        @description = description
    end

    def template(&)
        div(id: @title) do
            if @title || @description
                div(class: 'space-y-1 mb-4') do
                    render Typography::H4.new { @title } if @title
                    render Typography::P.new { @description } if @description
                end
            end

            # block rendered
            div(class: 'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
                div(class: 'preview flex min-h-[350px] w-full justify-center p-10 items-center', &)
            end

            # block source
            div(class: 'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
                div(class: "w-full rounded-md [&_pre]:my-0 [&_pre]:max-h-[350px] [&_pre]:overflow-auto") do
                    div(data_rehype_pretty_code_fragment: "") do
                        pre(class: "mb-4 mt-6 max-h-[650px] overflow-x-auto rounded-md border text-white bg-zinc-950 py-4 dark:bg-zinc-900") do
                            code(class: "relative rounded px-6 py-[0.2rem] font-mono text-sm") do
                                "Hi"
                            end
                        end
                    end
                end
            end
        end
    end
end