# frozen_string_literal: true

class Typography::H3 < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    h3(**@attributes, class: tokens("scroll-m-20 text-2xl font-semibold tracking-tight", @attributes[:class]), &)
  end
end