# frozen_string_literal: true

class Typography::H2 < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    h2(**@attributes, class: tokens("scroll-m-20 text-3xl font-semibold tracking-tight transition-colors first:mt-0", @attributes[:class]), &)
  end
end
