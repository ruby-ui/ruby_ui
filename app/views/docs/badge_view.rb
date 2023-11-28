# frozen_string_literal: true

class Docs::BadgeView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: 'Badge', description: 'Displays a badge or a component that looks like a badge.')

      render Docs::VisualCodeExample.new(title: 'Default', context: self) do
        <<~RUBY
          render PhlexUI::Badge.new { "Badge" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Primary', context: self) do
        <<~RUBY
          render PhlexUI::Badge.new(variant: :primary) { 'Primary' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Outline', context: self) do
        <<~RUBY
          render PhlexUI::Badge.new(variant: :outline) { 'Outline' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Variants', context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center') do
            render PhlexUI::Badge.new(variant: :destructive) { 'Destructive' }
            render PhlexUI::Badge.new(variant: :warning) { 'Warning' }
            render PhlexUI::Badge.new(variant: :success) { 'Success' }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Other Colors', context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center') do
            render PhlexUI::Badge.new(variant: :red) { 'Red' }
            render PhlexUI::Badge.new(variant: :orange) { 'Orange' }
            render PhlexUI::Badge.new(variant: :amber) { 'Amber' }
            render PhlexUI::Badge.new(variant: :yellow) { 'Yellow' }
            render PhlexUI::Badge.new(variant: :lime) { 'Lime' }
            render PhlexUI::Badge.new(variant: :green) { 'Green' }
            render PhlexUI::Badge.new(variant: :emerald) { 'Emerald' }
            render PhlexUI::Badge.new(variant: :teal) { 'Teal' }
            render PhlexUI::Badge.new(variant: :cyan) { 'Cyan' }
            render PhlexUI::Badge.new(variant: :sky) { 'Sky' }
            render PhlexUI::Badge.new(variant: :blue) { 'Blue' }
            render PhlexUI::Badge.new(variant: :indigo) { 'Indigo' }
            render PhlexUI::Badge.new(variant: :violet) { 'Violet' }
            render PhlexUI::Badge.new(variant: :purple) { 'Purple' }
            render PhlexUI::Badge.new(variant: :fuchsia) { 'Fuchsia' }
            render PhlexUI::Badge.new(variant: :pink) { 'Pink' }
            render PhlexUI::Badge.new(variant: :rose) { 'Rose' }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Sizes', context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center items-center') do
            render PhlexUI::Badge.new(size: :sm) { "Small" }
            render PhlexUI::Badge.new(size: :md) { "Medium" }
            render PhlexUI::Badge.new(size: :lg) { "Large" }
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def render_variant(variant)
    render PhlexUI::Badge.new(variant: variant) { variant.to_s.capitalize }
  end
end
