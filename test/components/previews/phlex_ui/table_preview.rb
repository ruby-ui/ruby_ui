# frozen_string_literal: true

module PhlexUi
  class TablePreview < Lookbook::Preview
    # Default TablePreview
    # ---------------
    def default
      render(TestView.new) do
        Table do
          TableCaption { "Employees at Acme inc." }
          TableHeader do
            TableRow do
              TableHead { "Name" }
              TableHead { "Email" }
              TableHead { "Status" }
              TableHead(class: "text-right") { "Role" }
            end
          end

          TableBody do
            [
              {identifier: "INV-0001", status: "Active", method: "Credit Card", amount: 100},
              {identifier: "INV-0002", status: "Active", method: "Bank Transfer", amount: 230},
              {identifier: "INV-0003", status: "Pending", method: "PayPal", amount: 350},
              {identifier: "INV-0004", status: "Inactive", method: "Credit Card", amount: 10}
            ].each do |invoice|
              TableRow do
                TableCell(class: "font-medium") { invoice[:identifier] }
                TableCell { invoice[:status] }
                TableCell { invoice[:method] }
                TableCell(class: "text-right") { invoice[:amount] }
              end
            end
          end

          TableFooter do
            TableRow do
              TableHead(class: "font-medium", colspan: 3) { "Total" }
              TableHead(class: "font-medium text-right") { "780" }
            end
          end
        end
      end
    end
  end
end
