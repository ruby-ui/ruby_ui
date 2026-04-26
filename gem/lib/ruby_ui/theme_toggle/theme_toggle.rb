# frozen_string_literal: true

module RubyUI
  class ThemeToggle < Base
    def view_template(&)
      div(**attrs, &)
    end
  end
end
