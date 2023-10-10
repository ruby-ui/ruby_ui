# frozen_string_literal: true

class Typography::Large < ApplicationComponent
  def template(&)
    div(class: "text-lg font-semibold", &)
  end
end