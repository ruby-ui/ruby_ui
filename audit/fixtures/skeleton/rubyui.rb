# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/skeleton (strings in content.yml).
  class Skeleton < Phlex::HTML
    include RubyUI

    def view_template
      div(id: "skeleton-fixture", class: "flex w-96 flex-col gap-8") do
        div(class: "flex flex-col gap-3") do
          div(class: "text-sm font-medium", data: {audit_trigger: true}) { "Avatar" }
          div(class: "flex w-full items-center gap-4") do
            Skeleton(class: "size-10 shrink-0 rounded-full", data: {audit_skeleton: true})
            div(class: "grid gap-2") do
              Skeleton(class: "h-4 w-[150px]", data: {audit_skeleton: true})
              Skeleton(class: "h-4 w-[100px]", data: {audit_skeleton: true})
            end
          end
        end
        div(class: "flex flex-col gap-3") do
          div(class: "text-sm font-medium") { "Text" }
          div(class: "flex w-full flex-col gap-2") do
            Skeleton(class: "h-4 w-full", data: {audit_skeleton: true})
            Skeleton(class: "h-4 w-full", data: {audit_skeleton: true})
            Skeleton(class: "h-4 w-3/4", data: {audit_skeleton: true})
          end
        end
        div(class: "flex flex-col gap-3") do
          div(class: "text-sm font-medium") { "Form" }
          div(class: "flex w-full flex-col gap-7") do
            div(class: "flex flex-col gap-3") do
              Skeleton(class: "h-4 w-20", data: {audit_skeleton: true})
              Skeleton(class: "h-10 w-full", data: {audit_skeleton: true})
            end
            Skeleton(class: "h-9 w-24", data: {audit_skeleton: true})
          end
        end
        div(class: "flex flex-col gap-3") do
          div(class: "text-sm font-medium") { "Table" }
          div(class: "flex w-full flex-col gap-2") do
            2.times do
              div(class: "flex gap-4") do
                Skeleton(class: "h-4 flex-1", data: {audit_skeleton: true})
                Skeleton(class: "h-4 w-24", data: {audit_skeleton: true})
                Skeleton(class: "h-4 w-20", data: {audit_skeleton: true})
              end
            end
          end
        end
      end
    end
  end
end
