# frozen_string_literal: true

class Badge < ApplicationComponent
  def initialize(variant: :primary, **attributes)
    @variant = variant
    @attributes = attributes
  end

  def template(&)
    case @variant
    when :primary
      div(class: tokens("inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-primary text-primary-foreground shadow hover:bg-primary/80", -> { @attributes[:class]} => @attributes[:class]), &)
    when :secondary
      div(class: tokens("inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80", -> { @attributes[:class]} => @attributes[:class]), &)
    when :outline
      div(class: tokens("inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 text-foreground", -> { @attributes[:class]} => @attributes[:class]), &)
    when :destructive
      div(class: tokens("inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-destructive text-destructive-foreground shadow hover:bg-destructive/80", -> { @attributes[:class]} => @attributes[:class]), &)
    end
  end
end
