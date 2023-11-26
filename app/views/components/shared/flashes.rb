# frozen_string_literal: true

class Shared::Flashes < ApplicationComponent
    def initialize(notice: nil, alert: nil)
        @notice = notice
        @alert = alert
    end

    def template(&)
        ol(
            tabindex: "-1",
            class:
                "pointer-events-none fixed top-0 z-[100] flex max-h-screen w-full flex-col-reverse p-4 sm:bottom-0 sm:right-0 sm:top-auto sm:flex-col md:max-w-[420px] gap-y-1",
        ) do
            render Shared::Flash.new(variant: :notice, description: @notice) if @notice
            render Shared::Flash.new(variant: :alert, description: @alert) if @alert
        end
    end
end