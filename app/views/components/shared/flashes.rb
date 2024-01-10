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
      vote_now_toast if show_vote_now_notice?
    end
  end

  private

  def show_vote_now_notice?
    Current.user_subscribed? && 
    Current.user&.votes&.count == 0 &&
    # current page is not votes index page
    !helpers.current_page?(helpers.votes_path)
  end

  def vote_now_toast
    render Shared::Flash.new(
      variant: :notice,
      title: "Vote for components",
      description: "Vote for components to dismiss this notice"
    ) do
      render PhlexUI::Link.new(variant: :primary, href: helpers.votes_path, size: :sm) do
        plain "Vote now"
      end
    end
  end
end