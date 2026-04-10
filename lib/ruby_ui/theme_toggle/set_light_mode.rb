# frozen_string_literal: true

module RubyUI
  class SetLightMode
    include ComponentBase

    private

    def default_attrs
      {
        class: "dark:hidden",
        data: {controller: "ruby-ui--theme-toggle", action: "click->ruby-ui--theme-toggle#setDarkTheme"}
      }
    end
  end
end
