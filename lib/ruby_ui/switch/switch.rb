# frozen_string_literal: true

module RubyUI
  class Switch < Base
    def view_template
      attrs => { include_hidden:, **input_attrs }

      label(
        role: "switch",
        class: "peer inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background has-[:disabled]:cursor-not-allowed has-[:disabled]:opacity-50 bg-input has-[:checked]:bg-primary"
      ) do
        input(type: "hidden", name: attrs[:name], value: "0") if include_hidden
        input(**input_attrs)

        span(class: "pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg ring-0 transition-transform translate-x-0 peer-checked:translate-x-5 ")
      end
    end

    private

    def default_attrs
      {
        class: "hidden peer",
        type: "checkbox",
        include_hidden: true,
        value: "1"
      }
    end
  end
end
