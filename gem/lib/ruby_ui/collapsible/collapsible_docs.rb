# frozen_string_literal: true

class Views::Docs::Collapsible < Views::Base
  def view_template
    component = "Collapsible"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Collapsible", description: "An interactive component which expands/collapses a panel.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Collapsible do
            div(class: "flex items-center justify-between space-x-4 px-4 py-2") do
              h4(class: "text-sm font-semibold") { " @joeldrapper starred 3 repositories" }
              CollapsibleTrigger do
                Button(variant: :ghost, icon: true) do
                  chevron_icon
                  span(class: "sr-only") { "Toggle" }
                end
              end
            end

            div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
              "phlex-ruby/phlex"
            end

            CollapsibleContent do
              div(class: 'space-y-2 mt-2') do
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "phlex-ruby/phlex-rails"
                end
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "ruby-ui/ruby_ui"
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open", context: self) do
        <<~RUBY
          Collapsible(open: true) do
            div(class: "flex items-center justify-between space-x-4 px-4 py-2") do
              h4(class: "text-sm font-semibold") { " @joeldrapper starred 3 repositories" }
              CollapsibleTrigger do
                Button(variant: :ghost, icon: true) do
                  chevron_icon
                  span(class: "sr-only") { "Toggle" }
                end
              end
            end

            div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
              "phlex-ruby/phlex"
            end

            CollapsibleContent do
              div(class: 'space-y-2 mt-2') do
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "phlex-ruby/phlex-rails"
                end
                div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                  "ruby-ui/ruby_ui"
                end
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

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
