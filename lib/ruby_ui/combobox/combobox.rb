# frozen_string_literal: true

module RubyUI
  class Combobox < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby_ui--combobox",
          ruby_ui__combobox_open_value: "false",
          action: "click@window->ruby_ui--combobox#onClickOutside",
          ruby_ui__combobox_ruby_ui__combobox_content_outlet: ".combobox-content",
          ruby_ui__combobox_ruby_ui__combobox_item_outlet: ".combobox-item"
        },
        class: "group/combobox w-full relative"
      }
    end
  end
end
