# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module PhlexUi
  class PopoverPreview < Lookbook::Preview
    # Default Popover
    # ---------------
    # @param placement [String] select { choices: ['top', 'top-start', 'top-end', 'right', 'right-start', 'right-end', 'left', 'left-start', 'left-end', 'bottom', 'bottom-start', 'bottom-end'] }
    def default(placement: "top")
      render(TestView.new) do
        Popover(options: {placement:}) do
          PopoverTrigger(class: "w-full") do
            Button(variant: :outline) { "Open Popover" }
          end

          PopoverContent(class: "w-40") do
            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              plain(helpers.lucide_icon("circle-user", class: "w-4 h-4 mr-2"))
              plain("Profile")
            end

            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              plain(helpers.lucide_icon("cog", class: "w-4 h-4 mr-2"))
              plain("Settings")
            end

            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              plain(helpers.lucide_icon("log-out", class: "w-4 h-4 mr-2"))
              plain("Logout")
            end
          end
        end
      end
    end

    # Trigger Popover
    # ---------------
    def trigger
      render(TestView.new) do
        Popover(options: {trigger: "click"}) do
          PopoverTrigger(class: "w-full") do
            Button(variant: :outline) { "Open Popover" }
          end

          PopoverContent(class: "w-40") do
            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              plain(helpers.lucide_icon("circle-user", class: "w-4 h-4 mr-2"))
              plain("Profile")
            end

            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              plain(helpers.lucide_icon("cog", class: "w-4 h-4 mr-2"))
              plain("Settings")
            end

            Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do
              link.plain(helpers.lucide_icon("log-out", class: "w-4 h-4 mr-2"))
              link.plain("Logout")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
