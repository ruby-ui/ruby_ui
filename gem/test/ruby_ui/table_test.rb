# frozen_string_literal: true

require "test_helper"

class RubyUI::TableTest < ComponentTest
  def test_render_with_all_items
    invoices = [
      {identifier: "INV-0001", status: "Active", method: "Credit Card", amount: 100},
      {identifier: "INV-0002", status: "Active", method: "Bank Transfer", amount: 230},
      {identifier: "INV-0003", status: "Pending", method: "PayPal", amount: 350},
      {identifier: "INV-0004", status: "Inactive", method: "Credit Card", amount: 100}
    ]

    output = phlex do
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
            RubyUI.TableCell(colspan: 3) { "Total" }
            RubyUI.TableCell(class: "text-right") { invoices.sum { |invoice| invoice[:amount] } }
          end
        end
      end
    end

    assert_match(/Total/, output)
  end

  def test_every_part_has_its_data_slot
    output = phlex do
      RubyUI.Table do
        RubyUI.TableCaption { "Caption" }
        RubyUI.TableHeader { RubyUI.TableRow { RubyUI.TableHead { "Head" } } }
        RubyUI.TableBody { RubyUI.TableRow { RubyUI.TableCell { "Cell" } } }
        RubyUI.TableFooter { RubyUI.TableRow { RubyUI.TableCell { "Foot" } } }
      end
    end

    {
      "table-container" => "div", "table" => "table", "table-caption" => "caption",
      "table-header" => "thead", "table-body" => "tbody", "table-footer" => "tfoot",
      "table-row" => "tr", "table-head" => "th", "table-cell" => "td"
    }.each do |slot, tag|
      assert_match(/<#{tag}\b[^>]*\bdata-slot="#{slot}"/, output, "#{slot} on <#{tag}>")
    end
  end

  def test_container_scrolls_horizontally_and_attrs_go_to_the_table
    output = phlex { RubyUI.Table(id: "invoices", class: "min-w-96") { "" } }

    assert_match(/<div data-slot="table-container" class="relative w-full overflow-x-auto">/, output)
    assert_match(/<table[^>]*id="invoices"/, output)
    assert_match(/<table[^>]*class="[^"]*min-w-96/, output)
  end

  def test_footer_classes_are_valid_tokens
    output = phlex { RubyUI.TableFooter { "" } }

    assert_match(%r{class="border-t bg-muted/50 font-medium \[&>tr\]:last:border-b-0"}, output)
  end

  def test_head_and_cell_do_not_wrap
    head = phlex { RubyUI.TableHead { "Head" } }
    cell = phlex { RubyUI.TableCell { "Cell" } }

    assert_match(/whitespace-nowrap/, head)
    assert_match(/text-foreground/, head)
    refute_match(/text-muted-foreground/, head)
    assert_match(/whitespace-nowrap/, cell)
    [head, cell].each { |output| refute_match(/translate-y/, output) }
  end

  def test_row_is_highlighted_while_a_control_inside_is_expanded
    output = phlex { RubyUI.TableRow { "" } }

    assert_match(%r{has-aria-expanded:bg-muted/50}, output)
    assert_match(/data-\[state=selected\]:bg-muted/, output)
  end

  def test_a_caller_slot_replaces_the_default
    {
      RubyUI::Table => "table", RubyUI::TableHeader => "thead", RubyUI::TableBody => "tbody",
      RubyUI::TableFooter => "tfoot", RubyUI::TableRow => "tr", RubyUI::TableHead => "th",
      RubyUI::TableCell => "td", RubyUI::TableCaption => "caption"
    }.each do |klass, tag|
      output = phlex { RubyUI.public_send(klass.name.split("::").last, data: {slot: "custom", column: "email"}) { "x" } }

      assert_match(/<#{tag}\b[^>]*data-slot="custom"/, output, klass.name)
      assert_match(/data-column="email"/, output, klass.name)
    end
    assert_match(/data-slot="table-container"/, phlex { RubyUI.Table(data: {slot: "custom"}) { "" } })
  end

  def test_checkbox_columns_drop_the_right_padding
    [phlex { RubyUI.TableHead { "" } }, phlex { RubyUI.TableCell { "" } }].each do |output|
      assert_match(/\[&amp;:has\(\[data-slot=checkbox\]\)\]:pr-0|\[&:has\(\[data-slot=checkbox\]\)\]:pr-0/, output)
    end
  end
end
