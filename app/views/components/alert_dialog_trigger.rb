# frozen_string_literal: true

class AlertDialogTrigger < ApplicationComponent
  def template(&)
    # This will trigger stimulus action
    div(data: { action: "click->alert-dialog#open" }, class: 'inline-block', &)
  end
end
