# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/data_table (strings in content.yml),
  # composed as the docs demo (docs/app/views/docs/data_table_demo/index.rb).
  class DataTable < Phlex::HTML
    include RubyUI

    ROWS = [
      [1, "Cover page", "Cover page", "In Process", "Eddie Lake"],
      [2, "Table of contents", "Table of contents", "Done", "Eddie Lake"],
      [3, "Executive summary", "Narrative", "Done", "Jamik Tashpulatov"]
    ].freeze
    TOGGLES = [
      {key: :type, label: "Type"},
      {key: :status, label: "Status"},
      {key: :reviewer, label: "Reviewer"}
    ].freeze

    def view_template
      div(class: "p-6") do
        DataTable(id: "audit_data_table") do
          DataTableToolbar do
            div
            div(class: "flex items-center gap-2") do
              DataTableColumnToggle(columns: TOGGLES, label: "Columns", data: {audit_trigger: true})
            end
          end

          DataTableForm(id: "audit_data_table_form", action: "") do
            div(class: "overflow-hidden rounded-lg border") do
              Table do
                TableHeader(class: "bg-muted") do
                  TableRow do
                    TableHead(class: "w-8") { div(class: "flex items-center justify-center") { DataTableSelectAllCheckbox() } }
                    TableHead { "Header" }
                    TableHead(data: {column: "type"}) { "Type" }
                    TableHead(data: {column: "status"}) { "Status" }
                    TableHead(data: {column: "reviewer"}) { "Reviewer" }
                  end
                end
                TableBody do
                  ROWS.each do |id, header, type, status, reviewer|
                    TableRow do
                      TableCell(class: "w-8") { div(class: "flex items-center justify-center") { DataTableRowCheckbox(value: id, label: "Select row") } }
                      TableCell { header }
                      TableCell(data: {column: "type"}) do
                        div(class: "w-32") { Badge(variant: :outline, class: "px-1.5 text-muted-foreground") { type } }
                      end
                      TableCell(data: {column: "status"}) do
                        Badge(variant: :outline, class: "px-1.5 text-muted-foreground") do
                          (status == "Done") ? circle_check_icon : loader_icon
                          plain status
                        end
                      end
                      TableCell(data: {column: "reviewer"}) { reviewer }
                    end
                  end
                end
              end
            end
          end

          DataTablePaginationBar do
            DataTableSelectionSummary(total_on_page: ROWS.size)
            div(class: "flex w-full items-center gap-8 lg:w-fit") do
              DataTablePerPageSelect(path: "#", value: 10, options: [5, 10, 25, 50], label: "Rows per page", class: "hidden lg:flex")
              DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "#")
            end
          end
        end
      end
    end

    private

    # lucide circle-check, as the block's status cell for "Done"
    def circle_check_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true",
        class: "fill-green-500 dark:fill-green-400") do |s|
        s.circle(cx: "12", cy: "12", r: "10")
        s.path(d: "m16 9-5.5 5.5L8 12")
      end
    end

    # lucide loader, as the block's status cell otherwise
    def loader_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
        ["M12 2v4", "m16.2 7.8 2.9-2.9", "M18 12h4", "m16.2 16.2 2.9 2.9", "M12 18v4", "m4.9 19.1 2.9-2.9", "M2 12h4", "m4.9 4.9 2.9 2.9"].each { |d| s.path(d:) }
      end
    end
  end
end
