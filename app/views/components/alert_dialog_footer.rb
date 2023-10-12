# frozen_string_literal: true

class AlertDialogFooter < ApplicationComponent
  def template(&)
    div(class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", &)
  end
end