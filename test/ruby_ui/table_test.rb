# frozen_string_literal: true

require "test_helper"

class RubyUI::TableTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    invoices = [
      {identifier: "INV-0001", status: "Active", method: "Credit Card", amount: 100},
      {identifier: "INV-0002", status: "Active", method: "Bank Transfer", amount: 230},
      {identifier: "INV-0003", status: "Pending", method: "PayPal", amount: 350},
      {identifier: "INV-0004", status: "Inactive", method: "Credit Card", amount: 100}
    ]

    output = phlex_context do
      RubyUI.Table do
        RubyUI.TableCaption { "Employees at Acme inc." }
        RubyUI.TableHeader do
          RubyUI.TableRow do
            RubyUI.TableHead { "Name" }
            RubyUI.TableHead { "Email" }
            RubyUI.TableHead { "Status" }
            RubyUI.TableHead(class: "text-right") { "Role" }
          end
        end
        RubyUI.TableBody do
          invoices.each do |invoice|
            RubyUI.TableRow do
              RubyUI.TableCell(class: "font-medium") { invoice[:identifier] }
              RubyUI.TableCell { invoice[:status] }
              RubyUI.TableCell { invoice[:method] }
              RubyUI.TableCell(class: "text-right") { invoice[:amount] }
            end
          end
        end
        RubyUI.TableFooter do
          RubyUI.TableRow do
            RubyUI.TableHead(class: "font-medium", colspan: 3) { "Total" }
            RubyUI.TableHead(class: "font-medium text-right") { invoices.sum { |invoice| invoice[:amount] } }
          end
        end
      end
    end

    assert_match(/Total/, output)
  end
end
