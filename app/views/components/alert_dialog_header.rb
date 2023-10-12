# frozen_string_literal: true

class AlertDialogHeader < ApplicationComponent  
  def template(&)
    div(class: "flex flex-col space-y-2 text-center sm:text-left", &)
  end
end
