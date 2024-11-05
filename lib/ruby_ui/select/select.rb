# frozen_string_literal: true

module RubyUI
  class Select < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "rbui--select",
          rbui__select_open_value: "false",
          action: "click@window->rbui--select#clickOutside",
          rbui__select_rbui__select_item_outlet: ".item"
        },
        class: "group/select w-full relative"
      }
    end
  end
end
