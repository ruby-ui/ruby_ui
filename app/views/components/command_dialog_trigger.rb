# frozen_string_literal: true

class CommandDialogTrigger < ApplicationComponent
  DEFAULT_KEYBINDINGS = [
    "keydown.ctrl+k@window",
    "keydown.meta+k@window"
  ].freeze

  def initialize(keybindings: [], **attributes)
    @keybindings = keybindings.any? ? keybindings : DEFAULT_KEYBINDINGS
    @attributes = attributes
  end

  def template(&block)
    div(
      **@attributes,
      data: {
        action: action_value,
      },
      &block
    )
  end

  private

  def action_value
    ([ "click->dialog#open" ] + @keybindings.map { |kb| "#{kb}->dialog#open" }).join(' ')
  end
end
