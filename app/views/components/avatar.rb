# frozen_string_literal: true

class Avatar < ApplicationComponent
  SIZES = {
    xs: "h-4 w-4 text-[0.5rem]",
    sm: "h-6 w-6 text-xs",
    md: "h-10 w-10 text-base",
    lg: "h-14 w-14 text-xl",
    xl: "h-20 w-20 text-3xl"
  }

  def initialize(size: :md, **attributes)
    @size_classes = SIZES[size]
    @attributes = attributes
  end

  def template(&)
    span(
      **@attributes,
      class: tokens("relative flex #{@size_classes} shrink-0 overflow-hidden rounded-full", -> { @attributes[:class] } => @attributes[:class]),
      &)
  end
end
