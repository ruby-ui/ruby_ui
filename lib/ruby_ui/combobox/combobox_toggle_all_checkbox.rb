# frozen_string_literal: true

module RubyUI
  class ComboboxToggleAllCheckbox < Base
    def view_template
      render RubyUI::ComboboxCheckbox.new(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__combobox_target: "toggle",
          action: "change->ruby-ui--combobox#toggleInputs"
        }
      }
    end
  end
end
