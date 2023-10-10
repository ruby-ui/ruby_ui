# frozen_string_literal: true

class Typography::H1 < ApplicationComponent
  def template(&)
    h1(class: "scroll-m-20 text-4xl font-extrabold tracking-tight lg:text-5xl", &)
  end
end
