# frozen_string_literal: true

class Tabs < ApplicationComponent
  def initialize(default_value: nil, **attributes)
    @default_value = default_value
    @attributes = attributes
  end

  def template(&)
    div(data: { controller: 'tabs', tabs_default_value_value: @default_value }, **@attributes, &)
  end
end
