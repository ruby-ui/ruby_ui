# frozen_string_literal: true

class AlertDialogTitle < ApplicationComponent
  def template(&)
    h2(class: "text-lg font-semibold", &)
  end
end
