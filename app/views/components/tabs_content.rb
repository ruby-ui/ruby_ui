# frozen_string_literal: true

class TabsContent < ApplicationComponent
  def initialize(value:, **attributes)
    @value = value
    @attributes = attributes
  end

  def template(&)
    div(**@attributes, data: { tabs_target: :content, value: @value }, class: tokens("mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 hidden", @attributes[:class]), &)
  end
end
