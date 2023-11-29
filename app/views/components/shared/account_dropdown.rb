# frozen_string_literal: true

class Shared::AccountDropdown < ApplicationComponent
    def template(&block)
        render PhlexUI::DropdownMenu.new(options: { placement: 'bottom-end' }) do
            render PhlexUI::DropdownMenu::Trigger.new do
                block.call
            end
            render PhlexUI::DropdownMenu::Content.new do
                if current_user
                    div(class: 'px-2 py-1.5') do
                        span(class: 'text-muted-foreground text-sm') { "Signed in as" }
                        p(class: 'text-sm font-medium') { current_user&.email }
                    end
                    render PhlexUI::DropdownMenu::Separator.new
                    render PhlexUI::DropdownMenu::Item.new(href: "#") { "Support" }
                    render PhlexUI::DropdownMenu::Item.new(href: helpers.license_path) { "License" }
                    render PhlexUI::DropdownMenu::Separator.new
                    case current_user&.plan
                    when "personal"
                        render PhlexUI::DropdownMenu::Item.new(href: ENV['TEAM_STRIPE_LINK']) { "Upgrade to Team license" }
                    when "team"
                        render PhlexUI::DropdownMenu::Item.new(href: "#") { "Add team members" }
                    else
                        render PhlexUI::DropdownMenu::Item.new(href: helpers.root_path(anchor: :pricing)) { "Get all access" }
                    end
                    render PhlexUI::DropdownMenu::Separator.new
                    render PhlexUI::DropdownMenu::Item.new(href: helpers.signin_path, data: { turbo_method: :delete }) { "Sign out" }
                else
                    render PhlexUI::DropdownMenu::Item.new(href: helpers.new_signin_path) { "Sign in" }
                end
            end
        end
    end
end