# frozen_string_literal: true

class AlertDescription < ApplicationComponent
  def template(&)
    div(class: 'text-sm [&_p]:leading-relaxed', &)
  end
end
