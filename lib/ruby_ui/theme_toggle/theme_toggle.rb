# frozen_string_literal: true

module RubyUI
  class ThemeToggle < Base
    def view_template(&)
      div(**attrs, &)
    end

    def light_mode(**user_attrs, &)
      light_attrs = mix(default_light_attrs, user_attrs)
      div(**light_attrs, &)
    end

    def dark_mode(**user_attrs, &)
      dark_attrs = mix(default_dark_attrs, user_attrs)
      div(**dark_attrs, &)
    end

    private

    def default_attrs
      {
        data: {controller: "ruby_ui--theme-toggle"}
      }
    end

    def default_light_attrs
      {
        class: "dark:hidden",
        data: {action: "click->ruby_ui--theme-toggle#setDarkTheme"}
      }
    end

    def default_dark_attrs
      {
        class: "hidden dark:inline-block",
        data: {action: "click->ruby_ui--theme-toggle#setLightTheme"}
      }
    end
  end
end
