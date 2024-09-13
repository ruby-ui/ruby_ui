# frozen_string_literal: true

module Rbui
  class ClipboardPreview < Lookbook::Preview
    # Default Clipboard
    # ---------------
    def default
      render(TestView.new) do
        Clipboard(success: "Copied!", error: "Copy failed!", class: "relative", options: {placement: "top"}) do
          ClipboardSource(class: "hidden") { span { "Born rich!!!" } }

          ClipboardTrigger do
            Link(href: "#", class: "gap-1") do
              TypographyP(size: :small, class: "text-primary") { "Copy the secret of success!!!" }
            end
          end
        end
      end
    end
  end
end
