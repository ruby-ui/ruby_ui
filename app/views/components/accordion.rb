# frozen_string_literal: true

class Accordion < ApplicationComponent
  def template(&)
    div(data: { controller: 'accordion' }, class: 'w-full', &)
  end
end
