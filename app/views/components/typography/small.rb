# frozen_string_literal: true

class Typography::Small < ApplicationComponent
  def template(&)
    small(class: "text-sm font-medium leading-none", &)
  end
end