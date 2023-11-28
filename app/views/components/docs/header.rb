# frozen_string_literal: true

class Docs::Header < ApplicationComponent
    def initialize(title: nil, description: nil, premium: false)
        @title = title
        @description = description
        @premium = premium
    end

    def template
        div(class: 'space-y-2') do
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
end