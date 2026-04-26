# frozen_string_literal: true

module RubyUI
  class SetLightMode < Base
    def view_template(&)
      div(**attrs, &)
    end

    def default_attrs
      {
        class: "dark:hidden",
        data: {controller: "ruby-ui--theme-toggle", action: "click->ruby-ui--theme-toggle#setDarkTheme"}
      }
    end
  end
end
