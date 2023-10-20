# frozen_string_literal: true

class Codeblock < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(class: "w-full rounded-md [&_pre]:my-0 [&_pre]:max-h-[350px] [&_pre]:overflow-auto") do
            pre(data: { controller: 'codeblock' }, class: "px-4 mb-4 mt-6 max-h-[650px] overflow-x-auto rounded-md border text-white bg-zinc-950 py-4 dark:bg-zinc-900") do
                code(class: "relative rounded px-6 py-[0.2rem] font-mono text-sm", &)
            end
        end
    end
end
