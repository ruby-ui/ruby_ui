# frozen_string_literal: true

class Docs::Header < ApplicationComponent
  def initialize(title: nil, description: nil, premium: false)
    @title = title
    @description = description
    @premium = premium
  end

  def view_template
    div(class: "space-y-2") do
      TypographyH1 { @title }
      TypographyLead { @description }
    end
  end

  private

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
