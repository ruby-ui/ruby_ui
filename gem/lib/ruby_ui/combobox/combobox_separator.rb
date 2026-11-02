# frozen_string_literal: true

module RubyUI
  class ComboboxSeparator < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        role: "separator",
        aria: {orientation: "horizontal"},
        data: {slot: "combobox-separator", ruby_ui__combobox_target: "separator"},
        class: "-mx-1 my-1 h-px bg-border"
      }
    end
  end
end
