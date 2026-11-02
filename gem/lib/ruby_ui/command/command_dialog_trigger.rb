# frozen_string_literal: true

module RubyUI
  # Opens the CommandDialog on click and on its keybindings (⌘K / Ctrl+K by
  # default; Stimulus key filters, e.g. "keydown.meta+j@window").
  class CommandDialogTrigger < Base
    DEFAULT_KEYBINDINGS = [
      "keydown.ctrl+k@window",
      "keydown.meta+k@window"
    ].freeze

    def initialize(keybindings: DEFAULT_KEYBINDINGS, **attrs)
      @keybindings = keybindings.map { |kb| "#{kb}->ruby-ui--dialog#open" }
      super(**attrs)
    end

    def view_template(&)
      render DialogTrigger.new(**attrs, &)
    end

    private

    def default_attrs
      {data: {action: @keybindings.join(" ")}}
    end
  end
end
