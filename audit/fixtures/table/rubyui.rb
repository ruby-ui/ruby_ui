# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/table (strings in content.yml).
  class Table < Phlex::HTML
    include RubyUI

    INVOICES = [
      ["INV001", "Paid", "Credit Card", "$250.00"],
      ["INV002", "Pending", "PayPal", "$150.00"],
      ["INV003", "Unpaid", "Bank Transfer", "$350.00"]
    ].freeze

    def view_template
      div(class: "w-[640px]") do
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
            INVOICES.each_with_index do |(invoice, status, method, amount), i|
              row_attrs = (i == 1) ? {data: {state: "selected", audit_trigger: true}} : {}
              TableRow(**row_attrs) do
                TableCell(class: "font-medium") { invoice }
                TableCell { status }
                TableCell { method }
                TableCell(class: "text-right") { amount }
              end
            end
          end
          TableFooter do
            TableRow do
              TableCell(colspan: 3) { "Total" }
              TableCell(class: "text-right") { "$2,500.00" }
            end
          end
        end
      end
    end
  end
end
