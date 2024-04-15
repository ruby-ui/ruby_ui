# frozen_string_literal: true

module Steps
  class Step < ApplicationComponent
    def initialize(number: 1, last: false)
      @number = number
      @last = last
    end

    attr_writer :last

    def view_template(&block)
      div(class: "relative flex space-x-4 md:space-x-8") do
        div(class: "flex-shrink-0 h-full") do
          div(class: "flex-0 flex items-center justify-center h-6 w-6 rounded-md border border-amber-500/20 bg-amber-100 dark:bg-amber-100/20 text-amber-700 dark:text-amber-200") do
            p(class: "font-medium text-sm") { @number }
          end
          # vertical line unless last
          hr(class: "absolute left-3 top-6 -ml-px h-full w-px bg-amber-500/20") unless @last
        end
        div(class: "flex-1 space-y-2 pb-10 overflow-hidden -mt-0.5", &block)
      end
    end
  end
end
