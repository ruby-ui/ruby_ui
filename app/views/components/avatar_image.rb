# frozen_string_literal: true

class AvatarImage < ApplicationComponent
  def initialize(src:, alt:, **attributes)
    @src = src
    @alt = alt
    @attributes = attributes
  end

  def template
    img(
        loading: "lazy",
        **@attributes,
        class: tokens("aspect-square h-full w-full", -> { @attributes[:class] } => @attributes[:class]),
        alt: @alt,
        src: @src
    )
  end
end
