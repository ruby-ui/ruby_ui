# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module PhlexUi
  class DropdownMenuPreview < Lookbook::Preview
    # Default DropdownMenu
    # ---------------
    # @param placement [String] select { choices: ['top', 'top-start', 'top-end', 'right', 'right-start', 'right-end', 'left', 'left-start', 'left-end', 'bottom', 'bottom-start', 'bottom-end'] }
    def default(placement: "top")
      render(TestView.new) do
        DropdownMenu(options: {placement:}) do
          DropdownMenuTrigger(class: "w-full") do
            Button(variant: :outline) { "Open" }
          end

          DropdownMenuContent do
            DropdownMenuLabel { "My Account" }
            DropdownMenuSeparator()
            DropdownMenuItem(href: "#") { "Profile" }
            DropdownMenuItem(href: "#") { "Billing" }
            DropdownMenuItem(href: "#") { "Team" }
            DropdownMenuItem(href: "#") { "Subscription" }
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
