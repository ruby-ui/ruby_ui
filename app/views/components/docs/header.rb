# frozen_string_literal: true

class Docs::Header < ApplicationComponent
    def initialize(title: nil, description: nil, premium: false, pre_release_only: false)
        @title = title
        @description = description
        @premium = premium
        @pre_release_only = pre_release_only
    end

    def template
        div(class: 'space-y-2') do
            if @pre_release_only
                render PhlexUI::Alert.new(variant: :warning, class: 'mb-8') do
                    alert_icon
                    render PhlexUI::Alert::Title.new { "Early-access only" }
                    render PhlexUI::Alert::Description.new { "This page is only available to paying users at this time." }
                end
            end
            render Docs::PremiumBadge.new if locked?
            render PhlexUI::Typography::H1.new { @title }
            render PhlexUI::Typography::Lead.new { @description }
        end
    end

    private

    def locked?
        return false unless @premium
        return true if current_user.nil?
        current_user.not_subscribed?
    end

    def alert_icon
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewbox: "0 0 24 24",
            stroke_width: "1.5",
            stroke: "currentColor",
            class: "w-5 h-5"
        ) do |s|
            s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                d:
                "M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"
            )
        end
    end
end