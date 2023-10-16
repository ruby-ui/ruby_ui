# frozen_string_literal: true

class Typography::P < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    p(**@attributes, class: tokens("leading-7 [&:not(:first-child)]:mt-6", @attributes[:class]), &)
  end
end