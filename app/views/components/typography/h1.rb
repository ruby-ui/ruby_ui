# frozen_string_literal: true

class Typography::H1 < ApplicationComponent
  def template(&)
    h1(class: "scroll-m-20 text-3xl font-bold tracking-tight lg:text-4xl", &)
  end
end
