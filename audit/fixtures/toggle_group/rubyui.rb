# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/toggle_group (strings in content.yml).
  class ToggleGroup < Phlex::HTML
    include RubyUI

    def view_template
      div(id: "toggle-group-fixture", class: "flex flex-col items-start gap-6") do
        ToggleGroup(type: :single, name: "alignment", variant: :outline, spacing: 0, aria: {label: "Alignment"}) do |g|
          g.ToggleGroupItem(value: "left", data: {audit_trigger: true}) { "Left" }
          g.ToggleGroupItem(value: "center") { "Center" }
          g.ToggleGroupItem(value: "right") { "Right" }
        end
        ToggleGroup(type: :multiple, name: "formatting", value: %w[bold], spacing: 1, aria: {label: "Formatting"}) do |g|
          g.ToggleGroupItem(value: "bold") { "Bold" }
          g.ToggleGroupItem(value: "italic") { "Italic" }
          g.ToggleGroupItem(value: "underline") { "Underline" }
        end
        ToggleGroup(type: :single, name: "size", value: "medium", variant: :outline, size: :sm, spacing: 0, orientation: :vertical, aria: {label: "Size"}) do |g|
          g.ToggleGroupItem(value: "small") { "Small" }
          g.ToggleGroupItem(value: "medium") { "Medium" }
          g.ToggleGroupItem(value: "large") { "Large" }
        end
        ToggleGroup(type: :multiple, name: "range", variant: :outline, spacing: 2, disabled: true, aria: {label: "Range"}) do |g|
          g.ToggleGroupItem(value: "day") { "Day" }
          g.ToggleGroupItem(value: "week") { "Week" }
        end
      end
    end
  end
end
