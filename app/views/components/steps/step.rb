# frozen_string_literal: true

module Steps
    class Step < ApplicationComponent
        def initialize(number: 1, last: false)
            @number = number
            @last = last
        end

        def last=(last)
            @last = last
        end

        def template(&)
            div(class: 'relative flex space-x-8') do
                div(class: 'flex-shrink-0 h-full') do
                    div(class: 'flex-0 flex items-center justify-center h-6 w-6 rounded-md border bg-background') do
                        p(class: 'font-medium text-sm') { @number }
                    end
                    # vertical line unless last
                    hr(class: 'absolute left-3 top-6 -ml-px h-full w-px bg-border') unless @last
                end
                div(class: 'flex-grow space-y-2 pb-10', &)
            end
        end
    end
end
