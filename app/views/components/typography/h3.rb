# frozen_string_literal: true

class Typography::H3 < ApplicationComponent
  def template(&)
    h3(class: "scroll-m-20 text-2xl font-semibold tracking-tight", &)
  end
end