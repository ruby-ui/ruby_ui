# frozen_string_literal: true

class AlertDialogCancel < ApplicationComponent
  def template(&)
    render Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }, class: 'mt-2 sm:mt-0', &)
  end
end