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
          controller: "rbui--combobox",
          rbui__combobox_open_value: "false",
          action: "click@window->rbui--combobox#onClickOutside",
          rbui__combobox_rbui__combobox_content_outlet: ".combobox-content",
          rbui__combobox_rbui__combobox_item_outlet: ".combobox-item"
        },
        class: "group/combobox w-full relative"
      }
    end
  end
end
