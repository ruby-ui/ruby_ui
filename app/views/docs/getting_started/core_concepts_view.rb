# frozen_string_literal: true

class Docs::GettingStarted::CoreConceptsView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Core concepts", description: "Below are some of the core concepts that will help you understand how PhlexUI works under the hood.")

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "The 3 Ingredients" }
        render PhlexUI::Typography::P.new { "PhlexUI is built on top of 3 core ingredients: " }
        render PhlexUI::Typography::List.new do
          render PhlexUI::Typography::ListItem.new(class: 'space-y-2') do
            span(class: 'font-bold') { "Phlex Components" }
            plain " - A framework for building fast, reusable, testable views in pure Ruby."
          end
          render PhlexUI::Typography::ListItem.new(class: 'space-y-2') do
            span(class: 'font-bold') { "TailwindCSS" }
            plain " - A utility-first CSS framework for rapidly building custom designs."
          end
          render PhlexUI::Typography::ListItem.new(class: 'space-y-2') do
            span(class: 'font-bold') { "Stimulus JS" }
            plain " - A modest JavaScript framework for the HTML you already have."
          end
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new(class: 'flex items-center gap-x-2') do 
          plain "Builder Components"
          render PhlexUI::Badge.new(variant: :primary, size: :sm) { "WIP" }
        end

        render PhlexUI::Alert.new do
          puzzle_icon
          render PhlexUI::Alert::Title.new { "Work in progress" }
          render PhlexUI::Alert::Description.new { "Only recently added, Builder Components are still a work in progress. They are not yet available for all components." }
        end
        
        render PhlexUI::Typography::P.new do
          plain "Drawing from Rails' emphasis on development speed, we've created "
          render PhlexUI::Typography::InlineCode.new { "::Builder" }
          plain " components. These function similarly to Rails' helper methods, enabling quicker component implementation. They use the same underlying components but provide a more streamlined interface."
        end

        render PhlexUI::Typography::P.new do
          plain "For example, the "
          render PhlexUI::Typography::InlineCode.new { "PhlexUI::Form::Builder" }
          plain " component is a wrapper around the "
          render PhlexUI::Typography::InlineCode.new { "PhlexUI::Form" }
          plain ", "
          render PhlexUI::Typography::InlineCode.new { "PhlexUI::Form::Input" }
          plain ", "
          render PhlexUI::Typography::InlineCode.new { "PhlexUI::Form::Label" }
          plain " components, and provides a more efficient interface for building forms."
        end

        render PhlexUI::Typography::H3.new { "Same form, different approaches" }

        render Docs::VisualCodeExample.new(title: 'Without Builder', context: self) do
          <<~RUBY
            render PhlexUI::Form.new(class: 'w-full max-w-sm') do
              render PhlexUI::Form::Spacer.new do
                render PhlexUI::Form::Item.new do
                  render PhlexUI::Label.new(for: "username") { "Username" }
                  render PhlexUI::Input.new(type: "string", placeholder: "@joeldrapper", id: "username")
                  render PhlexUI::Hint.new { "Can only contain letters, numbers, and underscores." }
                end
                render PhlexUI::Button.new(type: "submit") { "Submit" }
              end
            end
          RUBY
        end

        render Docs::VisualCodeExample.new(title: 'With Builder', context: self) do
          <<~RUBY
            render PhlexUI::Form::Builder.new(class: 'w-full max-w-sm') do |f|
              f.input "username", type: :string, placeholder: "@joeldrapper", hint: "Can only contain letters, numbers, and underscores."
              f.button { "Submit" }
            end
          RUBY
        end
      end
    end
  end

  private

  def puzzle_icon
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
          "M14.25 6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 01-.657.643 48.39 48.39 0 01-4.163-.3c.186 1.613.293 3.25.315 4.907a.656.656 0 01-.658.663v0c-.355 0-.676-.186-.959-.401a1.647 1.647 0 00-1.003-.349c-1.036 0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 1.003-.349.283-.215.604-.401.959-.401v0c.31 0 .555.26.532.57a48.039 48.039 0 01-.642 5.056c1.518.19 3.058.309 4.616.354a.64.64 0 00.657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 01-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 2.25 1.875 0 .369-.128.713-.349 1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 005.427-.63 48.05 48.05 0 00.582-4.717.532.532 0 00-.533-.57v0c-.355 0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 1.003.349.283.215.604.401.96.401v0a.656.656 0 00.658-.663 48.422 48.422 0 00-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 01-.61-.58v0z"
      )
    end
  end
end
