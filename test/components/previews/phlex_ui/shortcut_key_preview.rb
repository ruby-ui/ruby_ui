# frozen_string_literal: true

module PhlexUi
  class ShortcutKeyPreview < Lookbook::Preview
    def default
      render(TestView.new) do
        div(class: "flex flex-col items-center gap-y-4") do
          ShortcutKey do
            span(class: "text-xs") { "⌘" }
            plain "K"
          end
          p(class: "text-muted-foreground text-sm text-center") { "Note this does not trigger anything, it is purely a visual prompt" }
        end
      end
    end
  end
end
