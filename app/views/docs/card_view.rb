# frozen_string_literal: true

class Docs::CardView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Card" }
        render Typography::P.new { "Displays a card with header, content, and footer." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render Card.new(class: 'w-96') do
          render CardHeader.new do
            render CardTitle.new { "You might like \"3D Renders\"" }
            render CardDescription.new { "@joeldrapper" }
          end
          render CardContent.new do
            render AspectRatio.new(aspect_ratio: "16/9") do
              img(
                alt: "Placeholder",
                loading: "lazy",
                class: "rounded-md object-cover",
                style:
                  "position:absolute;height:100%;width:100%;inset:0;color:transparent",
                src:
                  "https://images.unsplash.com/photo-1667373509687-4c4574541218?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3132&q=80"
              )
            end
          end
          render CardFooter.new(class: 'flex justify-end gap-x-2') do
            render Button.new(variant: :outline) { "No thanks" }
            render Button.new(variant: :primary) { "See more" }
          end
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
