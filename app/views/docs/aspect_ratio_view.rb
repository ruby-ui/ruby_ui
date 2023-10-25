# frozen_string_literal: true

class Docs::AspectRatioView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Aspect Ratio" }
        render Typography::P.new { "Displays content within a desired ratio." }
      end

      render Docs::VisualCodeExample.new(title: "16/9", context: self) do
        <<~RUBY
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "4/3", context: self) do
        <<~RUBY
          render AspectRatio.new(aspect_ratio: "4/3") do
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "1/1", context: self) do
        <<~RUBY
          render AspectRatio.new(aspect_ratio: "1/1") do
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "21/9", context: self) do
        <<~RUBY
          render AspectRatio.new(aspect_ratio: "21/9") do
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
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
