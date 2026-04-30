# frozen_string_literal: true

class Views::Docs::DataTableDemo::Index < Views::Base
  FRAME_ID = "employees_list"
  FORM_ID = "employees_form"

  TOGGLABLE_COLUMNS = [
    {key: :email, label: "Email"},
    {key: :department, label: "Department"},
    {key: :status, label: "Status"},
    {key: :salary, label: "Salary"}
  ].freeze

  BADGE_VARIANTS = {
    "Active" => :success,
    "Inactive" => :destructive,
    "On Leave" => :warning
  }.freeze

  def initialize(employees:, total_count:, page:, per_page:, sort:, direction:, search:)
    @employees = employees
    @total_count = total_count
    @page = page
    @per_page = per_page
    @sort = sort
    @direction = direction
    @search = search
  end

  def view_template
    div(class: "p-6") { render_table }
  end

  private

  def render_table
    DataTable(id: FRAME_ID) do
      DataTableToolbar do
        DataTableSearch(
          path: docs_data_table_demo_path,
          frame_id: FRAME_ID,
          value: @search,
          placeholder: "Filter emails...",
          preserved_params: preserved_query.except("search")
        )
        div(class: "flex items-center gap-2") do
          DataTableColumnToggle(columns: TOGGLABLE_COLUMNS)
          DataTablePerPageSelect(
            path: docs_data_table_demo_path,
            frame_id: FRAME_ID,
            value: @per_page
          )
          DataTableBulkActions do
            Button(type: "submit", form: FORM_ID, formaction: docs_data_table_demo_bulk_delete_path, formmethod: "post", variant: :destructive, size: :sm) { "Delete" }
            Button(type: "submit", form: FORM_ID, formaction: docs_data_table_demo_bulk_export_path, formmethod: "post", variant: :outline, size: :sm) { "Export" }
          end
        end
      end

      DataTableForm(id: FORM_ID, action: "") do
        div(class: "rounded-md border") do
          Table do
            TableHeader do
              TableRow do
                TableHead(class: "w-10") { DataTableSelectAllCheckbox() }
                DataTableSortHead(column_key: :name, label: "Name", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query)
                DataTableSortHead(column_key: :email, label: "Email", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, data: {column: "email"})
                DataTableSortHead(column_key: :department, label: "Department", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, data: {column: "department"})
                TableHead(data: {column: "status"}) { plain "Status" }
                DataTableSortHead(column_key: :salary, label: "Salary", sort: @sort, direction: @direction, path: docs_data_table_demo_path, query: preserved_query, class: "text-right [&>a]:justify-end", data: {column: "salary"})
                TableHead(class: "w-12")
              end
            end

            TableBody do
              if @employees.empty?
                TableRow do
                  TableCell(colspan: 7, class: "h-24 text-center text-muted-foreground") { plain "No results." }
                end
              else
                @employees.each do |e|
                  TableRow do
                    TableCell(class: "w-10") { DataTableRowCheckbox(value: e.id, label: "Select row for #{e.name}") }
                    TableCell(class: "font-medium") { plain e.name }
                    TableCell(data: {column: "email"}) { plain e.email }
                    TableCell(data: {column: "department"}) { plain e.department }
                    TableCell(data: {column: "status"}) do
                      Badge(variant: BADGE_VARIANTS.fetch(e.status, :outline), size: :sm) { plain e.status }
                    end
                    TableCell(class: "text-right", data: {column: "salary"}) { plain view_context.number_to_currency(e.salary, precision: 0, unit: "$") }
                    TableCell(class: "w-12 text-right") { row_actions(e) }
                  end
                end
              end
            end
          end
        end
      end

      DataTablePaginationBar do
        DataTableSelectionSummary(total_on_page: @employees.size)
        DataTablePagination(
          page: @page,
          per_page: @per_page,
          total_count: @total_count,
          path: docs_data_table_demo_path,
          query: preserved_query
        )
      end
    end
  end

  def row_actions(employee)
    DropdownMenu do
      DropdownMenuTrigger do
        Button(type: "button", variant: :ghost, size: :icon, aria_label: "Open menu") do
          raw view_context.lucide_icon("ellipsis-vertical", class: "h-4 w-4")
        end
      end
      DropdownMenuContent do
        DropdownMenuLabel { plain "Actions" }
        DropdownMenuItem(href: "#") { plain "Copy employee ID" }
        DropdownMenuSeparator()
        DropdownMenuItem(href: "#") { plain "View details" }
        DropdownMenuItem(href: "#") { plain "View payments" }
      end
    end
  end

  def preserved_query
    {
      "search" => @search,
      "sort" => @sort,
      "direction" => @direction,
      "per_page" => @per_page.to_s
    }.compact_blank
  end
end
