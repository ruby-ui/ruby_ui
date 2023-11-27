# frozen_string_literal: true

class Shared::AccountDropdown < ApplicationComponent
    def initialize(user_id:)
        @user_id = user_id
        @email = User.find(@user_id)&.email
    end

    def template
        render PhlexUI::DropdownMenu.new(options: { placement: 'bottom-end' }) do
            render PhlexUI::DropdownMenu::Trigger.new do
                render PhlexUI::Button.new(variant: :ghost, class: 'hidden sm:inline-flex') do
                    plain "Account"
                    chevron_down_icon
                end
            end
            render PhlexUI::DropdownMenu::Content.new do
                div(class: 'px-2 py-1.5') do
                    span(class: 'text-muted-foreground text-sm') { "Signed in as" }
                    p(class: 'text-sm font-semibold') { @email }
                end
                render PhlexUI::DropdownMenu::Separator.new
                render PhlexUI::DropdownMenu::Item.new(href: helpers.signin_path, data: { turbo_method: :delete }) { "Sign out" }
            end
        end
    end

    private

    def chevron_down_icon
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            class: "w-4 h-4 ml-1"
        ) do |s|
            s.path(
                fill_rule: "evenodd",
                d:
                "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z",
                clip_rule: "evenodd"
            )
        end
    end
end