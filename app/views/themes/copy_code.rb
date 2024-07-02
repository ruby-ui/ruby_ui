# frozen_string_literal: true

module Themes
  class CopyCode < ApplicationComponent
    def initialize(theme:)
      @theme = theme
    end

    def view_template
      style do
        Theme::CSS.retrieve(@theme, with_directive: false)
      end
      Sheet do
        SheetTrigger do
          Button(variant: :primary) { "Copy Code" }
        end
        SheetContent(class: "sm:max-w-md w-screen flex flex-col h-screen overflow-y-scroll") do
          SheetHeader do
            SheetTitle { "Theme" }
            SheetDescription { "Copy and paste the following code into your CSS file." }
          end
          SheetMiddle(class: "flex-1 relative") do
            Codeblock(Theme::CSS.retrieve(@theme, with_directive: true), syntax: :css, class: "h-full max-h-none")
          end
        end
      end
    end
  end
end
