# frozen_string_literal: true

class Avatar < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    span(
      **@attributes,
      class: tokens("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", -> { @attributes[:class] } => @attributes[:class]),
      &)
  end
end
