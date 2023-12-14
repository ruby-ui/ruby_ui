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
      
      render PhlexUI::Card.new(class: 'mt-8 p-24 shadow-none') do
      end
    end
  end
end
