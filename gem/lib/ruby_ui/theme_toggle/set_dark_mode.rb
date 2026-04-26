# frozen_string_literal: true

module RubyUI
  class SetDarkMode < Base
    def view_template(&)
      div(**attrs, &)
    end

    def default_attrs
      {
        class: "hidden dark:inline-block",
        data: {controller: "ruby-ui--theme-toggle", action: "click->ruby-ui--theme-toggle#setLightTheme"}
      }
    end
  end
end
