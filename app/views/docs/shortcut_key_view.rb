# frozen_string_literal: true

class Docs::ShortcutKeyView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Shortcut Key" }
        render PhlexUI::Typography::P.new { "A component for displaying keyboard shortcuts." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "flex flex-col items-center gap-y-4") do
            render PhlexUI::ShortcutKey.new do
              span(class: "text-xs") { "⌘" }
              plain "K"
            end
            p(class: "text-muted-foreground text-sm text-center") { "Note this does not trigger anything, it is purely a visual prompt" }
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
