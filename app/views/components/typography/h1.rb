# frozen_string_literal: true

class Typography::H1 < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    h1(**@attributes, class: tokens("scroll-m-20 text-3xl font-semibold leading-normal lg:leading-normal tracking-tight lg:text-4xl", @attributes[:class]), &)
  end
end
