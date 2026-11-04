# frozen_string_literal: true

class Views::Docs::Table < Views::Base
  Invoice = Struct.new(:identifier, :status, :method, :amount)

  def view_template
    component = "Table"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Table", description: "A responsive table component.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "With footer", description: "Cells don't wrap: when the table is wider than its container, the container scrolls horizontally.", context: self) do
        <<~RUBY
          Table do
            TableCaption { "A list of your recent invoices." }
            TableHeader do
              TableRow do
                TableHead(class: "w-[100px]") { "Invoice" }
                TableHead { "Status" }
                TableHead { "Method" }
                TableHead(class: "text-right") { "Amount" }
              end
            end
            TableBody do
              invoices.each do |invoice|
                TableRow do
                  TableCell(class: "font-medium") { invoice.identifier }
                  TableCell { invoice.status }
                  TableCell { invoice.method }
                  TableCell(class: "text-right") { format_amount(invoice.amount) }
                end
              end
            end
            TableFooter do
              TableRow do
                TableCell(colspan: 3) { "Total" }
                TableCell(class: "text-right") { format_amount(invoices.sum(&:amount)) }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With badges", context: self) do
        <<~RUBY
          Table do
            TableHeader do
              TableRow do
                TableHead { "Invoice" }
                TableHead { "Status" }
                TableHead(class: "text-right") { "Amount" }
              end
            end
            TableBody do
              invoices.each do |invoice|
                TableRow do
                  TableCell(class: "font-medium") { invoice.identifier }
                  TableCell { render_status_badge(invoice.status) }
                  TableCell(class: "text-right") { format_amount(invoice.amount) }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With actions", description: "A row stays highlighted while a menu inside it is open (anything in it with aria-expanded=true).", context: self) do
        <<~RUBY
          Table do
            TableHeader do
              TableRow do
                TableHead { "Product" }
                TableHead { "Price" }
                TableHead(class: "text-right") { "Actions" }
              end
            end
            TableBody do
              [["Wireless Mouse", "$29.99"], ["Mechanical Keyboard", "$129.99"], ["USB-C Hub", "$49.99"]].each do |product, price|
                TableRow do
                  TableCell(class: "font-medium") { product }
                  TableCell { price }
                  TableCell(class: "text-right") do
                    DropdownMenu do
                      DropdownMenuTrigger do
                        Button(variant: :ghost, size: :icon, class: "size-8") do
                          more_icon
                          span(class: "sr-only") { "Open menu" }
                        end
                      end
                      DropdownMenuContent(align: :end) do
                        DropdownMenuItem { "Edit" }
                        DropdownMenuItem { "Duplicate" }
                        DropdownMenuSeparator()
                        DropdownMenuItem(variant: :destructive) { "Delete" }
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

  private

  def invoices
    [
      Invoice.new(identifier: "INV001", status: "Paid", method: "Credit Card", amount: 250),
      Invoice.new(identifier: "INV002", status: "Pending", method: "PayPal", amount: 150),
      Invoice.new(identifier: "INV003", status: "Unpaid", method: "Bank Transfer", amount: 350)
    ]
  end

  def format_amount(amount)
    "$#{amount}.00"
  end

  def render_status_badge(status)
    case status
    when "Paid"
      Badge(size: :sm, class: "bg-green-50 text-green-700 dark:bg-green-950 dark:text-green-300") { status }
    when "Pending"
      Badge(size: :sm, class: "bg-amber-50 text-amber-700 dark:bg-amber-950 dark:text-amber-300") { status }
    else
      Badge(variant: :destructive, size: :sm) { status }
    end
  end

  def more_icon
    svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor",
      stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
      s.circle(cx: "12", cy: "12", r: "1")
      s.circle(cx: "19", cy: "12", r: "1")
      s.circle(cx: "5", cy: "12", r: "1")
    end
  end
end
