# frozen_string_literal: true

class TabsList < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&)
    div(
      **@attributes,
      class: tokens("inline-flex h-9 items-center justify-center rounded-lg bg-muted p-1 text-muted-foreground", @attributes[:class]),
      &
    )
  end
end
