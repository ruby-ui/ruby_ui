# frozen_string_literal: true

class Docs::DialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Dialog" }
        render PhlexUI::Typography::P.new { "A window overlaid on either the primary window or another dialog window, rendering the content underneath inert." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::Dialog.new do
            render PhlexUI::Dialog::Trigger.new do
              render PhlexUI::Button.new { "Open Dialog" }
            end
            render PhlexUI::Dialog::Content.new do
              render PhlexUI::Dialog::Header.new do
                render PhlexUI::Dialog::Title.new { "PhlexUI to the rescue" }
                render PhlexUI::Dialog::Description.new { "PhlexUI helps you build accessible standard compliant web apps with ease" }
              end
              render PhlexUI::Dialog::Middle.new do
                render PhlexUI::AspectRatio.new(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                  img(
                    alt: "Placeholder",
                    loading: "lazy",
                    src:
                      helpers.image_path("pattern.jpg")
                  )
                end
              end
              render PhlexUI::Dialog::Footer.new do
                render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                render PhlexUI::Button.new { "Save" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", description: "Applicable for wider screens", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap justify-center gap-2') do
            render PhlexUI::Dialog.new do
              render PhlexUI::Dialog::Trigger.new do
                render PhlexUI::Button.new { "Small Dialog" }
              end
              render PhlexUI::Dialog::Content.new(size: :sm) do
                render PhlexUI::Dialog::Header.new do
                  render PhlexUI::Dialog::Title.new { "PhlexUI to the rescue" }
                  render PhlexUI::Dialog::Description.new { "PhlexUI helps you build accessible standard compliant web apps with ease" }
                end
                render PhlexUI::Dialog::Middle.new do
                  render PhlexUI::AspectRatio.new(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src:
                        helpers.image_path("pattern.jpg")
                    )
                  end
                end
                render PhlexUI::Dialog::Footer.new do
                  render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  render PhlexUI::Button.new { "Save" }
                end
              end
            end

            render PhlexUI::Dialog.new do
              render PhlexUI::Dialog::Trigger.new do
                render PhlexUI::Button.new { "Large Dialog" }
              end
              render PhlexUI::Dialog::Content.new(size: :lg) do
                render PhlexUI::Dialog::Header.new do
                  render PhlexUI::Dialog::Title.new { "PhlexUI to the rescue" }
                  render PhlexUI::Dialog::Description.new { "PhlexUI helps you build accessible standard compliant web apps with ease" }
                end
                render PhlexUI::Dialog::Middle.new do
                  render PhlexUI::AspectRatio.new(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src:
                        helpers.image_path("pattern.jpg")
                    )
                  end
                end
                render PhlexUI::Dialog::Footer.new do
                  render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  render PhlexUI::Button.new { "Save" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
