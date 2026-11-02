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
              columns_icon
              plain @label
              chevron_down_icon
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

    # lucide columns-3, as shadcn's trigger (data-icon tightens the button's padding)
    def columns_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true",
        data: {icon: "inline-start"}) do |s|
        s.rect(width: "18", height: "18", x: "3", y: "3", rx: "2")
        s.path(d: "M9 3v18")
        s.path(d: "M15 3v18")
      end
    end

    # lucide chevron-down
    def chevron_down_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true",
        data: {icon: "inline-end"}) do |s|
        s.path(d: "m6 9 6 6 6-6")
      end
    end

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
