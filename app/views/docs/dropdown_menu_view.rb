# frozen_string_literal: true

class Docs::DropdownMenuView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dropdown Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a button.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger(class: 'w-full') do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuLabel { "My Account" }
              DropdownMenuSeparator
              DropdownMenuItem(href: '#') { "Profile" }
              DropdownMenuItem(href: '#') { "Billing" }
              DropdownMenuItem(href: '#') { "Team" }
              DropdownMenuItem(href: '#') { "Subscription" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", description: "If the DropdownMenu conflicts with edge, it will auto-adjust it's placement", context: self) do
        <<~RUBY
          div(class: 'grid grid-cols-1 sm:grid-cols-3 gap-4') do
            # -- TOP --
            DropdownMenu(options: { placement: 'top' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'top' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'top-start' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'top-start' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'top-end' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'top-end' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            # -- BOTTOM --
            DropdownMenu(options: { placement: 'bottom' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'bottom' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'bottom-start' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'bottom-start' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'bottom-end' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'bottom-end' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            # -- LEFT --
            DropdownMenu(options: { placement: 'left' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'left' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'left-start' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'left-start' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'left-end' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'left-end' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            # -- RIGHT --
            DropdownMenu(options: { placement: 'right' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'right' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'right-start' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'right-start' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end

            DropdownMenu(options: { placement: 'right-end' }) do
              DropdownMenuTrigger(class: 'w-full') do
                Button(variant: :outline, class: 'w-full justify-center') { 'right-end' }
              end
              DropdownMenuContent do
                DropdownMenuLabel { "My Account" }
                DropdownMenuSeparator
                DropdownMenuItem(href: '#') { "Profile" }
                DropdownMenuItem(href: '#') { "Billing" }
                DropdownMenuItem(href: '#') { "Team" }
                DropdownMenuItem(href: '#') { "Subscription" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open on hover", context: self) do
        <<~RUBY
          DropdownMenu(options: { trigger: "mouseenter focus" }) do
            DropdownMenuTrigger(class: 'w-full') do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuLabel { "My Account" }
              DropdownMenuSeparator
              DropdownMenuItem(href: '#') { "Profile" }
              DropdownMenuItem(href: '#') { "Billing" }
              DropdownMenuItem(href: '#') { "Team" }
              DropdownMenuItem(href: '#') { "Subscription" }
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
      Docs::ComponentStruct.new(name: "DropdownMenu", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "DropdownMenuTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "DropdownMenuContent", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "DropdownMenuLabel", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/label.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "DropdownMenuItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "DropdownMenuSeparator", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dropdown_menu/separator.rb", built_using: :phlex)
    ]
  end
end
