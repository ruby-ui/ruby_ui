# frozen_string_literal: true

class Docs::DropdownMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Dropdown Menu" }
        render Typography::P.new { "Displays a menu to the user — such as a set of actions or functions — triggered by a button." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render DropdownMenu.new do
          render DropdownMenuTrigger.new do
            render Button.new(variant: :outline) { "Open" }
          end
          dropdown_content
        end
      end

      render Docs::VisualCodeExample.new(title: "Placement", description: "If the DropdownMenuContent conflicts with edge, it will change it's placement") do
        positions = %w[top right left bottom]
        div(class: 'grid grid-cols-1 sm:grid-cols-3 gap-4') do
          positions.each do |position|
            position_variants = [
              position,
              "#{position}-start",
              "#{position}-end"
            ]

            position_variants.each do |position_variant|
              render DropdownMenu.new(options: { placement: position_variant }) do
                render DropdownMenuTrigger.new do
                  render Button.new(variant: :outline, class: 'w-full justify-center') { position_variant }
                end
                dropdown_content
              end
            end
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "Open on hover") do
        render DropdownMenu.new(options: { trigger: "mouseenter focus" }) do
          render DropdownMenuTrigger.new do
            render Button.new(variant: :outline) { "Open" }
          end
          dropdown_content
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def dropdown_content
    render DropdownMenuContent.new do
      render DropdownMenuLabel.new { "My Account" }
      render DropdownMenuSeparator.new
      render DropdownMenuItem.new(href: '#') { "Profile" }
      render DropdownMenuItem.new(href: '#') { "Billing" }
      render DropdownMenuItem.new(href: '#') { "Team" }
      render DropdownMenuItem.new(href: '#') { "Subscription" }
    end
  end
end
