# frozen_string_literal: true

class Docs::DropdownMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Dropdown Menu" }
        render Typography::P.new { "Displays a menu to the user — such as a set of actions or functions — triggered by a button." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render DropdownMenu.new do
            render DropdownMenuTrigger.new do
              render Button.new(variant: :outline) { "Open" }
            end
            render DropdownMenuContent.new do
              render DropdownMenuLabel.new { "My Account" }
              render DropdownMenuSeparator.new
              render DropdownMenuItem.new(href: '#') { "Profile" }
              render DropdownMenuItem.new(href: '#') { "Billing" }
              render DropdownMenuItem.new(href: '#') { "Team" }
              render DropdownMenuItem.new(href: '#') { "Subscription" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", description: "If the DropdownMenuContent conflicts with edge, it will change it's placement", context: self) do
        <<~RUBY
          div(class: 'grid grid-cols-1 sm:grid-cols-3 gap-4') do
            # -- TOP --
            render DropdownMenu.new(options: { placement: 'top' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'top' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'top-start' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'top-start' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'top-end' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'top-end' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            # -- BOTTOM --
            render DropdownMenu.new(options: { placement: 'bottom' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'bottom-start' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom-start' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'bottom-end' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom-end' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            # -- LEFT --
            render DropdownMenu.new(options: { placement: 'left' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'left' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'left-start' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'left-start' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'left-end' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'left-end' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            # -- RIGHT --
            render DropdownMenu.new(options: { placement: 'right' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'right' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'right-start' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'right-start' }
              end
              render DropdownMenuContent.new do
                render DropdownMenuLabel.new { "My Account" }
                render DropdownMenuSeparator.new
                render DropdownMenuItem.new(href: '#') { "Profile" }
                render DropdownMenuItem.new(href: '#') { "Billing" }
                render DropdownMenuItem.new(href: '#') { "Team" }
                render DropdownMenuItem.new(href: '#') { "Subscription" }
              end
            end

            render DropdownMenu.new(options: { placement: 'right-end' }) do
              render DropdownMenuTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { 'right-end' }
              end
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open on hover", context: self) do
        <<~RUBY
          render DropdownMenu.new(options: { trigger: "mouseenter focus" }) do
            render DropdownMenuTrigger.new do
              render Button.new(variant: :outline) { "Open" }
            end
            render DropdownMenuContent.new do
              render DropdownMenuLabel.new { "My Account" }
              render DropdownMenuSeparator.new
              render DropdownMenuItem.new(href: '#') { "Profile" }
              render DropdownMenuItem.new(href: '#') { "Billing" }
              render DropdownMenuItem.new(href: '#') { "Team" }
              render DropdownMenuItem.new(href: '#') { "Subscription" }
            end
          end
        RUBY
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
