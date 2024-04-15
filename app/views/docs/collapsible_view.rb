# frozen_string_literal: true

class Docs::CollapsibleView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Collapsible", description: "An interactive component which expands/collapses a panel.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::Collapsible.new do
            div(class: "flex items-center justify-between space-x-4 px-4 py-2") do
              h4(class: "text-sm font-semibold") { " @joeldrapper starred 3 repositories" }
              render PhlexUI::Collapsible::Trigger.new do
                render PhlexUI::Button.new(variant: :ghost, icon: true) do
                  chevron_icon
                  span(class: "sr-only") { "Toggle" }
                end
              end
            end

            div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
              "phlex-ruby/phlex"
            end

            render PhlexUI::Collapsible::Content.new do
              div(class: 'space-y-2 mt-2') do
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "phlex-ruby/phlex-rails"
                end
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "PhlexUI/phlex_ui"
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open", context: self) do
        <<~RUBY
          render PhlexUI::Collapsible.new(open: true) do
            div(class: "flex items-center justify-between space-x-4 px-4 py-2") do
              h4(class: "text-sm font-semibold") { " @joeldrapper starred 3 repositories" }
              render PhlexUI::Collapsible::Trigger.new do
                render PhlexUI::Button.new(variant: :ghost, icon: true) do
                  chevron_icon
                  span(class: "sr-only") { "Toggle" }
                end
              end
            end

            div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
              "phlex-ruby/phlex"
            end

            render PhlexUI::Collapsible::Content.new do
              div(class: 'space-y-2 mt-2') do
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "phlex-ruby/phlex-rails"
                end
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "PhlexUI/phlex_ui"
                end
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "CollapsibleController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/collapsible_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::Collapsible", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/collapsible.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Collapsible::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/collapsible/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Collapsible::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/collapsible/content.rb", built_using: :phlex)
    ]
  end

  def chevron_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M10 3a.75.75 0 01.55.24l3.25 3.5a.75.75 0 11-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 01-1.1-1.02l3.25-3.5A.75.75 0 0110 3zm-3.76 9.2a.75.75 0 011.06.04l2.7 2.908 2.7-2.908a.75.75 0 111.1 1.02l-3.25 3.5a.75.75 0 01-1.1 0l-3.25-3.5a.75.75 0 01.04-1.06z",
        clip_rule: "evenodd"
      )
    end
  end
end
