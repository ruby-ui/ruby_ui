# frozen_string_literal: true

class Docs::BadgeView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Badge" }
        render Typography::P.new { "Displays a badge or a component that looks like a badge." }
      end

      render Docs::VisualCodeExample.new(title: 'Default', context: self) do
        <<~RUBY
          render Badge.new { "Badge" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Primary', context: self) do
        <<~RUBY
          render Badge.new(variant: :primary) { 'Primary' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Secondary', context: self) do
        <<~RUBY
          render Badge.new(variant: :secondary) { 'Secondary' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Outline', context: self) do
        <<~RUBY
          render Badge.new(variant: :outline) { 'Outline' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Destructive', context: self) do
        <<~RUBY
          render Badge.new(variant: :destructive) { 'Destructive' }
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def render_variant(variant)
    render Badge.new(variant: variant) { variant.to_s.capitalize }
  end
end
