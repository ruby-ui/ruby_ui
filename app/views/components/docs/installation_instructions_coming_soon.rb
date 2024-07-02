# frozen_string_literal: true

class Docs::InstallationInstructionsComingSoon < ApplicationComponent
  def initialize(title: "Installation", description: "Everything you need to know to get started with this component.")
    @title = title
    @description = description
  end

  def view_template(&block)
    render_header if @title || @description
  end

  def render_header
    div do
      div(class: "space-y-1 mb-4") do
        TypographyH4 { @title } if @title
        TypographyP { @description } if @description
      end
      div(class: "ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border") do
        div(class: "preview flex min-h-[350px] w-full justify-center p-10 items-center") do
          TypographyP(class: "text-muted-foreground text-center flex flex-col sm:flex-row items-center gap-y-2 gap-x-2") do
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
                  "M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456zM16.894 20.567L16.5 21.75l-.394-1.183a2.25 2.25 0 00-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 001.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 001.423 1.423l1.183.394-1.183.394a2.25 2.25 0 00-1.423 1.423z"
              )
            end
            plain "Installation instructions coming soon!"
          end
        end
      end
    end
  end
end
