# frozen_string_literal: true

class Themes::ShowView < ApplicationView
  def initialize(theme:)
    @theme = theme
  end

  def template
    render Shared::Container.new(size: :xl, class: 'py-8') do
      div(class: 'flex items-center justify-between') do
        div do
          render PhlexUI::Typography::H1.new { 'Themes' }
          render PhlexUI::Typography::Lead.new { 'Customize your app fast with hand-picked themes.' }
        end
        div(class: 'flex justify-center gap-x-2') do
          render Themes::CustomizePopover.new(theme: @theme)
          render Themes::CopyCode.new(theme: @theme)
        end
      end
      
      # Component grid
      div(class: 'flex flex-wrap justify-between -mx-2 pt-16') do
        div(class: 'flex flex-col gap-y-4 p-2 w-full sm:w-1/2 lg:w-1/3') do
          render Themes::Grid::RepoTabs.new
          render Themes::Grid::Card.new
        end
        div(class: 'flex flex-col gap-y-4 p-2 w-full sm:w-1/2 lg:w-1/3') do
          render Themes::Grid::Calendar.new
        end
        div(class: 'flex flex-col gap-y-4 p-2 w-full sm:w-1/2 lg:w-1/3') do
          render PhlexUI::Button.new(variant: :primary) { "Click me!" }
          render Themes::Grid::Command.new
        end
      end
    end
  end

  private
end
