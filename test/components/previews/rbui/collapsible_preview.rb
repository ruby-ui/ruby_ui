# frozen_string_literal: true

module RBUI
  class CollapsiblePreview < Lookbook::Preview
    # Default Collapsible
    # ---------------
    def default
      render(TestView.new) do
        Collapsible do
          div(class: "flex items-center justify-between space-x-4 px-4 py-2") do
            h4(class: "text-sm font-semibold") { " @joeldrapper starred 3 repositories" }
            CollapsibleTrigger do
              Button(variant: :ghost, icon: true) do
                plain(helpers.lucide_icon("chevrons-up-down", class: "w-4 h-4"))
                span(class: "sr-only") { "Toggle" }
              end
            end
          end

          div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
            "phlex-ruby/phlex"
          end

          CollapsibleContent do
            div(class: "space-y-2 mt-2") do
              div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                "phlex-ruby/phlex-rails"
              end
              div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
                "RBUI/rbui"
              end
            end
          end
        end
      end
    end
  end
end
