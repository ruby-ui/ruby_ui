# frozen_string_literal: true

class AlertDialogTrigger < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    # This will trigger stimulus action
    div(**@attributes, data: { action: "click->alert-dialog#open" }, class: tokens('inline-block', @attributes[:class]), &)
  end
end
