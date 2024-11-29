# frozen_string_literal: true

module RubyUI
  class ComboboxInput < Base
    def view_template
      select(**attrs)
    end

    private

    def default_attrs
      {
        class: "hidden",
        data: {
          ruby_ui__combobox_target: "select"
        }
      }
    end
  end
end
