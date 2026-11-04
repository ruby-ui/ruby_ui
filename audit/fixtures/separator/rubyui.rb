# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/separator (strings in content.yml).
  class Separator < Phlex::HTML
    include RubyUI

    def view_template
      div(id: "separator-fixture", class: "flex w-96 flex-col gap-8") do
        div(class: "flex flex-col gap-4 text-sm") do
          div(class: "flex flex-col gap-1") do
            div(class: "leading-none font-medium", data: {audit_trigger: true}) { "shadcn/ui" }
            div(class: "text-muted-foreground") { "The Foundation for your Design System" }
          end
          Separator(data: {audit_separator: true})
          div { "A set of beautifully designed components that you can customize, extend, and build on." }
        end
        div(class: "flex h-5 items-center gap-4 text-sm") do
          div { "Blog" }
          Separator(orientation: :vertical, data: {audit_separator: true})
          div { "Docs" }
          Separator(orientation: :vertical, data: {audit_separator: true})
          div { "Source" }
        end
        div(class: "flex items-center gap-4 text-sm") do
          div(class: "flex flex-col gap-1") do
            span(class: "font-medium") { "Settings" }
            span(class: "text-xs text-muted-foreground") { "Manage preferences" }
          end
          Separator(orientation: :vertical, data: {audit_separator: true})
          div(class: "flex flex-col gap-1") do
            span(class: "font-medium") { "Account" }
            span(class: "text-xs text-muted-foreground") { "Profile & security" }
          end
        end
      end
    end
  end
end
