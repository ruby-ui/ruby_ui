# frozen_string_literal: true

module RubyUI
  class ComboboxRadio < Base
    def view_template
      input(type: "radio", **attrs)
    end

    private

    def default_attrs
      {
        class: "aspect-square h-4 w-4 rounded-full border border-primary accent-primary text-primary shadow focus:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
        data: {
          ruby_ui__combobox_target: "input",
          action: "ruby-ui--combobox#inputChanged"
        }
      }
    end
  end
end
