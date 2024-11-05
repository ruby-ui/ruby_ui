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
          controller: "ruby_ui--dropdown-menu",
          action: "click@window->ruby_ui--dropdown-menu#onClickOutside",
          ruby_ui__dropdown_menu_options_value: @options.to_json
        }
      }
    end
  end
end
