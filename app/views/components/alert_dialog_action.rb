# frozen_string_literal: true

class AlertDialogAction < ApplicationComponent
  def template(&)
    render Button.new(variant: :primary, &)
  end
end