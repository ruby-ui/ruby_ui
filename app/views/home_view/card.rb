# frozen_string_literal: true

class HomeView::Card < ApplicationComponent
  include Phlex::DeferredRender

  def initialize(attributes = {})
    @attributes = attributes
    @title = attributes.delete(:title)
    @subtitle = attributes.delete(:subtitle) || nil
    @color = attributes.delete(:color) || :card

    @color_classes = {
      card: "bg-background border",
      primary: "bg-primary text-white",
      secondary: "bg-accent text-accent-foreground",
      # Add sky, violet, amber, lime, pink
      sky: "bg-sky-100 text-sky-950",
      violet: "bg-violet-100 text-violet-950",
      amber: "bg-amber-100 text-amber-950",
      lime: "bg-lime-100 text-lime-950",
      pink: "bg-pink-100 text-pink-950"
    }
  end

  def template(&block)
    div(**@attributes, class: tokens("relative flex flex-col p-6 md:p-10 rounded-2xl space-y-8 overflow-hidden", @attributes[:class], @color_classes[@color.to_sym])) do
      if @icon
        div(&@icon)
      end
      if @title || @subtitle
        div(class: "space-y-2") do
          h3(class: "font-semibold leading-none tracking-tight") { @title } if @title
          p { @subtitle } if @subtitle
        end
      end

      @content&.call
    end
  end

  def icon(&block)
    @icon = block
  end

  def content(&block)
    @content = block
  end
end
