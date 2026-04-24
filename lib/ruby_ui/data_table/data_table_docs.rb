# frozen_string_literal: true

class Views::Docs::DataTable < Views::Base
  Row = Struct.new(:id, :name, :email, :salary, :status, keyword_init: true)

  SAMPLE_ROWS = [
    Row.new(id: 1, name: "Alice", email: "alice@example.com", salary: 90_000, status: "Active"),
    Row.new(id: 2, name: "Bob", email: "bob@example.com", salary: 75_000, status: "Inactive"),
    Row.new(id: 3, name: "Carol", email: "carol@example.com", salary: 85_000, status: "Active")
  ].freeze

  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      component = "DataTable"
      render Docs::Header.new(
        title: component,
        description: "A Hotwire-first data table. Every interaction (sort, search, pagination) is a Rails request answered with HTML, swapped via Turbo Frame. Row selection uses form-first submission."
      )

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Server-driven table", context: self) do
        @@code = <<~RUBY
          DataTable(id: "employees") do
            DataTableToolbar do
              DataTableSearch(path: employees_path, value: @search)
              DataTablePerPageSelect(path: employees_path, value: @per_page)
            end

            div(class: "rounded-md border") do
              Table do
                TableHeader do
                  TableRow do
                    TableHead { "Name" }
                    DataTableSortHead(column_key: :email, label: "Email",
                                      sort: @sort, direction: @direction,
                                      path: employees_path)
                    TableHead(class: "text-right") { "Salary" }
                  end
                end
                TableBody do
                  @rows.each do |r|
                    TableRow do
                      TableCell { r.name }
                      TableCell { r.email }
                      TableCell(class: "text-right") { r.salary }
                    end
                  end
                end
              end
            end

            DataTablePaginationBar do
              DataTableSelectionSummary(total_on_page: @rows.size)
              DataTablePagination(page: @page, per_page: @per_page,
                                  total_count: @total_count, path: employees_path)
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Selection + bulk actions", context: self) do
        @@code = <<~RUBY
          FORM_ID = "employees_form"

          DataTable(id: "employees_select") do
            DataTableToolbar do
              DataTableSearch(path: employees_path, value: @search)
              DataTableBulkActions do
                Button(type: "submit", form: FORM_ID,
                       formaction: bulk_delete_employees_path,
                       formmethod: "post",
                       variant: :destructive, size: :sm) { "Delete" }
              end
            end

            DataTableForm(id: FORM_ID, action: "") do
              div(class: "rounded-md border") do
                Table do
                  TableHeader do
                    TableRow do
                      TableHead(class: "w-10") { DataTableSelectAllCheckbox() }
                      TableHead { "Name" }
                      TableHead { "Email" }
                    end
                  end
                  TableBody do
                    @rows.each do |r|
                      TableRow do
                        TableCell { DataTableRowCheckbox(value: r.id) }
                        TableCell { r.name }
                        TableCell { r.email }
                      end
                    end
                  end
                end
              end
            end

            DataTablePaginationBar do
              DataTableSelectionSummary(total_on_page: @rows.size)
              DataTablePagination(page: @page, per_page: @per_page,
                                  total_count: @total_count, path: employees_path)
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Column visibility", context: self) do
        @@code = <<~RUBY
          DataTable(id: "employees_cols") do
            DataTableToolbar do
              DataTableColumnToggle(columns: [
                {key: :email, label: "Email"},
                {key: :salary, label: "Salary"}
              ])
            end

            Table do
              TableHeader do
                TableRow do
                  TableHead { "Name" }
                  TableHead(data: {column: "email"}) { "Email" }
                  TableHead(data: {column: "salary"}) { "Salary" }
                end
              end
              TableBody do
                @rows.each do |r|
                  TableRow do
                    TableCell { r.name }
                    TableCell(data: {column: "email"}) { r.email }
                    TableCell(data: {column: "salary"}) { r.salary }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Expandable rows", context: self) do
        @@code = <<~RUBY
          DataTable(id: "employees_expand") do
            Table do
              TableHeader do
                TableRow do
                  TableHead(class: "w-10") { }
                  TableHead { "Name" }
                  TableHead { "Email" }
                end
              end
              TableBody do
                @rows.each do |r|
                  detail_id = "row-\#{r.id}-detail"
                  TableRow do
                    TableCell { DataTableExpandToggle(controls: detail_id, label: "Toggle \#{r.name}") }
                    TableCell { r.name }
                    TableCell { r.email }
                  end
                  TableRow(id: detail_id, class: "hidden", role: "region") do
                    TableCell(colspan: 3, class: "bg-muted/40") do
                      div(class: "p-4") do
                        p { "Salary: $\#{r.salary}" }
                        p { "Status: \#{r.status}" }
                      end
                    end
                  end
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
end
