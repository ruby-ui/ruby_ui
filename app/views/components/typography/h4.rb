# frozen_string_literal: true

class Typography::H4 < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    h4(class: tokens("scroll-m-20 text-lg font-medium tracking-tight", @attributes[:class]), &)
  end
end