# frozen_string_literal: true

class Docs::DropdownMenuView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dropdown Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a button.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::DropdownMenu.new do
            render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
              render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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
            render PhlexUI::DropdownMenu::Trigger.new(class: 'w-full') do
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

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PopoverController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/popover_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu::Label", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/label.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu::Item", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::DropdownMenu::Separator", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/separator.rb", built_using: :phlex)
    ]
  end
end
