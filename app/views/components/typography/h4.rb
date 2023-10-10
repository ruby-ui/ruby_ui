# frozen_string_literal: true

class Typography::H4 < ApplicationComponent
  def template(&)
    h4(class: "scroll-m-20 text-xl font-semibold tracking-tight", &)
  end
end