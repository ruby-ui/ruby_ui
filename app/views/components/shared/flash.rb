# frozen_string_literal: true

class Shared::Flash < ApplicationComponent
  # STYLE_CLASS = {
  #     notice: 'bg-primary text-primary-foreground',
  #     alert: 'bg-destructive text-destructive-foreground'
  # }
  # TRANSITION_CLASS = "transition ease-in-out data-[state=open]:animate-in data-[state=open]:fade-in data-[state=closed]:animate-out data-[state=closed]:duration-300 data-[state=open]:duration-500 inset-x-0 bottom-0 border-t data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom"

  def initialize(variant: :notice, title: nil, description: nil)
    @variant = variant.to_sym
    @description = description
    @title = title
  end

  def template(&block)
    li(
      role: "status",
      aria_live: "off",
      aria_atomic: "true",
      tabindex: "0",
      data_state: "open",
      data_controller: "dismissable",
      # data_swipe_direction: "right",
      class: tokens(
        "group pointer-events-auto relative flex w-full items-center justify-between space-x-2 overflow-hidden rounded-md p-4 pr-6 pt-3.5 shadow-lg transition-all data-[state=open]:animate-in data-[state=closed]:animate-out data-[swipe=end]:animate-out data-[state=closed]:fade-out-80 data-[state=closed]:slide-out-to-right-full data-[state=open]:slide-in-from-top-full data-[state=open]:sm:slide-in-from-bottom-full border",
        notice?: "bg-background text-foreground",
        alert?: "destructive group border-destructive bg-destructive text-destructive-foreground"
      ),
      style: "user-select:none; touch-action:none"
    ) do
      div(class: "grid gap-1") do
        if @title
          div(class: "text-sm font-semibold [&+div]:text-xs") { @title }
          div(class: "text-sm opacity-90") { @description }
        else
          div { @description }
        end
      end
      block&.call
      close_button # sits at top right of toast
    end
  end

  private

  def close_button
    button(
      type: "button",
      class: tokens(
        "absolute right-1 top-1 rounded-md p-1 opacity-0 transition-opacity focus:opacity-100 focus:outline-none focus:ring-1 focus:ring-ring group-hover:opacity-100",
        notice?: "text-foreground/50 hover:text-foreground",
        alert?: "text-destructive-foreground/50 hover:text-destructive-foreground focus:ring-destructive-foreground focus:ring-offset-destructive-foreground"
      ),

      data: {
        action: "click->dismissable#dismiss"
      }
    ) do
      x_icon
    end
  end

  def x_icon
    svg(
      width: "15",
      height: "15",
      viewbox: "0 0 15 15",
      fill: "none",
      xmlns: "http://www.w3.org/2000/svg",
      class: "h-4 w-4"
    ) do |s|
      s.path(
        d:
              "M11.7816 4.03157C12.0062 3.80702 12.0062 3.44295 11.7816 3.2184C11.5571 2.99385 11.193 2.99385 10.9685 3.2184L7.50005 6.68682L4.03164 3.2184C3.80708 2.99385 3.44301 2.99385 3.21846 3.2184C2.99391 3.44295 2.99391 3.80702 3.21846 4.03157L6.68688 7.49999L3.21846 10.9684C2.99391 11.193 2.99391 11.557 3.21846 11.7816C3.44301 12.0061 3.80708 12.0061 4.03164 11.7816L7.50005 8.31316L10.9685 11.7816C11.193 12.0061 11.5571 12.0061 11.7816 11.7816C12.0062 11.557 12.0062 11.193 11.7816 10.9684L8.31322 7.49999L11.7816 4.03157Z",
        fill: "currentColor",
        fill_rule: "evenodd",
        clip_rule: "evenodd"
      )
    end
  end

  def alert? = @variant == :alert

  def notice? = @variant == :notice
end
