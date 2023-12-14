# frozen_string_literal: true

module Themes
  class CopyCode < ApplicationComponent
    def initialize(theme:)
      @theme = theme
    end

    def template
      style do
        Theme::CSS.retrieve(@theme, with_directive: false)
      end
      render PhlexUI::Sheet.new do
        render PhlexUI::Sheet::Trigger.new do
          render PhlexUI::Button.new(variant: :primary) { "Copy Code" }
        end
        render PhlexUI::Sheet::Content.new(class: 'sm:max-w-md w-screen flex flex-col h-screen overflow-y-scroll') do
          render PhlexUI::Sheet::Header.new do
            render PhlexUI::Sheet::Title.new { "Theme" }
            render PhlexUI::Sheet::Description.new { "Copy and paste the following code into your CSS file." }
          end
          render PhlexUI::Sheet::Middle.new(class: 'flex-1 relative') do
            render PhlexUI::Codeblock.new(Theme::CSS.retrieve(@theme, with_directive: true), syntax: :css, class: 'h-full max-h-none')
          end
        end
      end
    end
  end
end