# frozen_string_literal: true

require "test_helper"

class RubyUI::TableTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Table.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert RubyUI::Table.new.attrs[:class]
    assert_includes RubyUI::Table.new.attrs[:class], "w-full"
    assert_includes RubyUI::Table.new.attrs[:class], "caption-bottom"
  end

  def test_user_class_merges
    t = RubyUI::Table.new(class: "extra-class")
    assert_includes t.attrs[:class], "extra-class"
    assert_includes t.attrs[:class], "w-full"
  end

  def test_table_body_default_class
    assert_includes RubyUI::TableBody.new.attrs[:class], "[&_tr:last-child]:border-0"
  end

  def test_table_caption_default_class
    assert_includes RubyUI::TableCaption.new.attrs[:class], "mt-4"
    assert_includes RubyUI::TableCaption.new.attrs[:class], "text-muted-foreground"
  end

  def test_table_cell_default_class
    assert_includes RubyUI::TableCell.new.attrs[:class], "p-2"
    assert_includes RubyUI::TableCell.new.attrs[:class], "align-middle"
  end

  def test_table_footer_default_class
    assert_includes RubyUI::TableFooter.new.attrs[:class], "bg-muted/50"
  end

  def test_table_head_default_class
    assert_includes RubyUI::TableHead.new.attrs[:class], "h-10"
    assert_includes RubyUI::TableHead.new.attrs[:class], "text-muted-foreground"
  end

  def test_table_header_default_class
    assert_includes RubyUI::TableHeader.new.attrs[:class], "[&_tr]:border-b"
  end

  def test_table_row_default_class
    assert_includes RubyUI::TableRow.new.attrs[:class], "border-b"
    assert_includes RubyUI::TableRow.new.attrs[:class], "hover:bg-muted/50"
  end

  def test_extra_attrs_pass_through
    t = RubyUI::Table.new(id: "my-table", data: {controller: "foo"})
    assert_equal "my-table", t.attrs[:id]
    assert_equal({controller: "foo"}, t.attrs[:data])
  end
end
