# frozen_string_literal: true

module RubyUI
  class DropdownMenu < Base
    def initialize(options: {}, **attrs)
      @options = options
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "rbui--dropdown-menu",
          action: "click@window->rbui--dropdown-menu#onClickOutside",
          rbui__dropdown_menu_options_value: @options.to_json
        }
      }
    end
  end
end
