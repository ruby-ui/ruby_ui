# frozen_string_literal: true

class HomeView::Steps < ApplicationComponent
  def initialize(attributes = {})
    @attributes = attributes
    @steps = attributes.delete(:steps) || []
  end

  def view_template(&block)
    div(**@attributes) do
      @steps.each_with_index do |step, index|
        render_step(step, index: index, last: index == @steps.length - 1)
      end
    end
  end

  def render_step(step, index:, last: false)
    div(class: "relative flex space-x-8") do
      div(class: "flex-shrink-0 h-full") do
        div(class: "flex-0 flex items-center justify-center h-6 w-6 rounded-full border bg-background") do
          p(class: "font-medium") { index + 1 }
        end
        # vertical line unless last
        hr(class: "absolute left-3 top-6 -ml-px h-full w-px bg-border") unless last
      end
      div(class: "flex-grow space-y-2 pb-10 pt-1") do
        h3(class: "font-semibold leading-none tracking-tight") { step[:title] } if step[:title]
        p { step[:description] } if step[:description]
      end
    end
  end
end
