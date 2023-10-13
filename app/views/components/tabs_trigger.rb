# frozen_string_literal: true

class TabsTrigger < ApplicationComponent
  def initialize(value:, **attributes)
    @value = value
    @attributes = attributes
  end

  def template(&)
    button(**@attributes, type: :button, data: { tabs_target: :trigger, action: "click->tabs#show", value: @value }, class: tokens("inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow", @attributes[:class]), &)
  end
end
