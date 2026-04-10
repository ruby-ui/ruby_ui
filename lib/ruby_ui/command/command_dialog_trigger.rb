# frozen_string_literal: true

module RubyUI
  class CommandDialogTrigger
    include ComponentBase

    DEFAULT_KEYBINDINGS = [
      "keydown.ctrl+k@window",
      "keydown.meta+k@window"
    ].freeze

    def initialize(keybindings: DEFAULT_KEYBINDINGS, **attrs)
      @keybindings = keybindings.map { |kb| "#{kb}->ruby-ui--command#open" }
      super(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          action: ["click->ruby-ui--command#open", @keybindings.join(" ")]
        }
      }
    end
  end
end
