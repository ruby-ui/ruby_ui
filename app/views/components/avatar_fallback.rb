# frozen_string_literal: true

class AvatarFallback < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    span(
        **@attributes,
        class: tokens("flex h-full w-full items-center justify-center rounded-full bg-muted", -> { @attributes[:class] } => @attributes[:class]),
        &
    )
  end
end
