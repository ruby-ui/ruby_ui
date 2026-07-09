# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Base
    def initialize(columns:, label: "Columns", **attrs)
      @columns = columns
      @label = label
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        render RubyUI::DropdownMenu.new do
          render RubyUI::DropdownMenuTrigger.new do
            render RubyUI::Button.new(variant: :outline, size: :sm) do
              plain @label
              # inline chevron-down SVG (lucide 24px, 1px stroke)
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                width: "16",
                height: "16",
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "currentColor",
                stroke_width: "2",
                stroke_linecap: "round",
                stroke_linejoin: "round",
                class: "w-4 h-4 ml-1"
              ) do |s|
                s.polyline(points: "6 9 12 15 18 9")
              end
            end
          end
          render RubyUI::DropdownMenuContent.new do
            @columns.each do |col|
              label(class: "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent") do
                input(
                  type: "checkbox",
                  checked: col.fetch(:visible, true),
                  class: [
                    "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                    "checked:bg-primary checked:text-primary-foreground dark:checked:bg-secondary checked:text-primary checked:border-primary"
                  ],
                  data: {
                    column_key: col[:key].to_s,
                    action: "change->ruby-ui--data-table-column-visibility#toggle"
                  }
                )
                span { plain col[:label] }
              end
            end
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
