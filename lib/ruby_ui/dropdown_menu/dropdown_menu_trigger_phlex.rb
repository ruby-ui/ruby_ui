# frozen_string_literal: true

module RubyUI
  class DropdownMenuTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {ruby_ui__dropdown_menu_target: "trigger", action: "click->ruby-ui--dropdown-menu#toggle"},
        class: "inline-block"
      }
    end
  end
end
