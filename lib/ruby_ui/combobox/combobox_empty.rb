# frozen_string_literal: true

module RubyUI
  class ComboboxEmpty < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "presentation",
        class: "hidden py-6 text-center text-sm",
        data: {
          ruby_ui__combobox_content_target: "empty"
        }
      }
    end
  end
end
