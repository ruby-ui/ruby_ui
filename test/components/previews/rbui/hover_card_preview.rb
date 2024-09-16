# frozen_string_literal: true

module RBUI
  class HoverCardPreview < Lookbook::Preview
    # Default HoverCard
    # ---------------
    def default
      render(TestView.new) do
        HoverCard do
          HoverCardTrigger { Button(variant: :link) { "@joeldrapper" } }

          HoverCardContent do
            div(class: "flex justify-between space-x-4") do
              Avatar do
                AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
                AvatarFallback { "JD" }
              end

              div(class: "space-y-1") do
                h4(class: "text-sm font-medium") { "@joeldrapper" }
                p(class: "text-sm") { "Creator of Phlex Components. Ruby on Rails developer." }
                div(class: "flex items-center pt-2") do
                  plain(helpers.lucide_icon("calendar-days", class: "mr-2 h-4 w-4 opacity-70"))
                  span(class: "text-xs text-muted-foreground") { "Joined December 2021" }
                end
              end
            end
          end
        end
      end
    end
  end
end
