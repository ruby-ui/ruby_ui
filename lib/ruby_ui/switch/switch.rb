# frozen_string_literal: true

module RubyUI
  class Switch < Base
    def initialize(include_hidden: true, checked_value: "1", unchecked_value: "0", **attrs)
      @include_hidden = include_hidden
      @checked_value = checked_value
      @unchecked_value = unchecked_value
      super(**attrs)
    end

    def view_template
      label(
        role: "switch",
        class: "peer inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background has-[:disabled]:cursor-not-allowed has-[:disabled]:opacity-50 bg-input has-[:checked]:bg-primary"
      ) do
        input(type: "hidden", name: attrs[:name], value: @unchecked_value) if @include_hidden
        input(**attrs.merge(type: "checkbox", class: "hidden peer", value: @checked_value))

        span(class: "pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg ring-0 transition-transform translate-x-0 peer-checked:translate-x-5 ")
      end
    end
  end
end
