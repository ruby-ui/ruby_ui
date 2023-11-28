# frozen_string_literal: true

class Docs::DropdownMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dropdown Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a button.")

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::DropdownMenu.new do
            render PhlexUI::DropdownMenu::Trigger.new do
              render PhlexUI::Button.new(variant: :outline) { "Open" }
            end
            render PhlexUI::DropdownMenu::Content.new do
              render PhlexUI::DropdownMenu::Label.new { "My Account" }
              render PhlexUI::DropdownMenu::Separator.new
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", description: "If the PhlexUI::DropdownMenu conflicts with edge, it will auto-adjust it's placement", context: self) do
        <<~RUBY
          div(class: 'grid grid-cols-1 sm:grid-cols-3 gap-4') do
            # -- TOP --
            render PhlexUI::DropdownMenu.new(options: { placement: 'top' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'top' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'top-start' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'top-start' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'top-end' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'top-end' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            # -- BOTTOM --
            render PhlexUI::DropdownMenu.new(options: { placement: 'bottom' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'bottom-start' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom-start' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'bottom-end' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'bottom-end' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            # -- LEFT --
            render PhlexUI::DropdownMenu.new(options: { placement: 'left' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'left' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'left-start' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'left-start' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'left-end' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'left-end' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            # -- RIGHT --
            render PhlexUI::DropdownMenu.new(options: { placement: 'right' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'right' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'right-start' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'right-start' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end

            render PhlexUI::DropdownMenu.new(options: { placement: 'right-end' }) do
              render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { 'right-end' }
              end
              render PhlexUI::DropdownMenu::Content.new do
                render PhlexUI::DropdownMenu::Label.new { "My Account" }
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
                render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open on hover", context: self) do
        <<~RUBY
          render PhlexUI::DropdownMenu.new(options: { trigger: "mouseenter focus" }) do
            render PhlexUI::DropdownMenu::Trigger.new do
              render PhlexUI::Button.new(variant: :outline) { "Open" }
            end
            render PhlexUI::DropdownMenu::Content.new do
              render PhlexUI::DropdownMenu::Label.new { "My Account" }
              render PhlexUI::DropdownMenu::Separator.new
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
              render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
            end
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def dropdown_content
    render PhlexUI::DropdownMenu::Content.new do
      render PhlexUI::DropdownMenu::Label.new { "My Account" }
      render PhlexUI::DropdownMenu::Separator.new
      render PhlexUI::DropdownMenu::Item.new(href: '#') { "Profile" }
      render PhlexUI::DropdownMenu::Item.new(href: '#') { "Billing" }
      render PhlexUI::DropdownMenu::Item.new(href: '#') { "Team" }
      render PhlexUI::DropdownMenu::Item.new(href: '#') { "Subscription" }
    end
  end
end
