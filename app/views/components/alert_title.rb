# frozen_string_literal: true

class AlertTitle < ApplicationComponent
  def template(&)
    h5(class: 'mb-1 font-medium leading-none tracking-tight', &)
  end
end
