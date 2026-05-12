# frozen_string_literal: true

module RubyUI
  class ThemeToggle < Base
    def view_template(&block)
      RubyUI.Toggle(
        variant: :outline,
        size: :default,
        aria: {label: "Toggle theme"},
        data: {
          controller: "ruby-ui--toggle ruby-ui--theme-toggle",
          action: "ruby-ui--toggle:change->ruby-ui--theme-toggle#apply"
        },
        **attrs,
        &block
      )
    end
  end
end
