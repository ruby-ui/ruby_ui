# frozen_string_literal: true

class Docs::AlertView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Alert" }
        render Typography::P.new { "Displays a callout for user attention." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render Alert.new do
            icon
            render AlertTitle.new { "Alert Title" }
            render AlertDescription.new { "Alert description" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          render Alert.new(variant: :destructive) do
            icon
            render AlertTitle.new { "Alert Title" }
            render AlertDescription.new { "Alert description" }
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M10.05 4.575a1.575 1.575 0 10-3.15 0v3m3.15-3v-1.5a1.575 1.575 0 013.15 0v1.5m-3.15 0l.075 5.925m3.075.75V4.575m0 0a1.575 1.575 0 013.15 0V15M6.9 7.575a1.575 1.575 0 10-3.15 0v8.175a6.75 6.75 0 006.75 6.75h2.018a5.25 5.25 0 003.712-1.538l1.732-1.732a5.25 5.25 0 001.538-3.712l.003-2.024a.668.668 0 01.198-.471 1.575 1.575 0 10-2.228-2.228 3.818 3.818 0 00-1.12 2.687M6.9 7.575V12m6.27 4.318A4.49 4.49 0 0116.35 15m.002 0h-.002"
      )
    end
  end
end
