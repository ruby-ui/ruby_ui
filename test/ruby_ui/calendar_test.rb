# frozen_string_literal: true

require "test_helper"

class RubyUI::CalendarTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Calendar.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    cal = RubyUI::Calendar.new
    assert_includes cal.attrs[:class], "p-3"
    assert_includes cal.attrs[:class], "space-y-4"
  end

  def test_has_data_controller
    cal = RubyUI::Calendar.new
    assert_equal "ruby-ui--calendar", cal.attrs.dig(:data, :controller)
  end

  def test_default_date_format
    cal = RubyUI::Calendar.new
    assert_equal "yyyy-MM-dd", cal.attrs.dig(:data, :ruby_ui__calendar_format_value)
  end

  def test_custom_date_format
    cal = RubyUI::Calendar.new(date_format: "MM/dd/yyyy")
    assert_equal "MM/dd/yyyy", cal.attrs.dig(:data, :ruby_ui__calendar_format_value)
  end

  def test_input_id_outlet
    cal = RubyUI::Calendar.new(input_id: "#date")
    assert_equal "#date", cal.attrs.dig(:data, :ruby_ui__calendar_ruby_ui__calendar_input_outlet)
  end

  def test_selected_date
    cal = RubyUI::Calendar.new(selected_date: "2024-01-15")
    assert_equal "2024-01-15", cal.attrs.dig(:data, :ruby_ui__calendar_selected_date_value)
  end

  def test_calendar_body_target
    body = RubyUI::CalendarBody.new
    assert_equal "calendar", body.attrs.dig(:data, :ruby_ui__calendar_target)
  end

  def test_calendar_header_class
    header = RubyUI::CalendarHeader.new
    assert_includes header.attrs[:class], "flex"
    assert_includes header.attrs[:class], "justify-center"
  end

  def test_calendar_title_default_text
    title = RubyUI::CalendarTitle.new
    assert_equal "Month Year", title.default_text
    assert_includes title.attrs[:class], "text-sm"
  end

  def test_calendar_prev_attrs
    prev = RubyUI::CalendarPrev.new
    assert_equal "previous-month", prev.attrs[:name]
    assert_includes prev.attrs[:class], "absolute left-1"
  end

  def test_calendar_next_attrs
    nxt = RubyUI::CalendarNext.new
    assert_equal "next-month", nxt.attrs[:name]
    assert_includes nxt.attrs[:class], "absolute right-1"
  end

  def test_calendar_weekdays_days_constant
    assert_equal 7, RubyUI::CalendarWeekdays::DAYS.length
    assert_includes RubyUI::CalendarWeekdays::DAYS, "Monday"
  end

  def test_calendar_days_base_class
    days = RubyUI::CalendarDays.new
    assert_includes days.selected_date_button_class, "bg-primary"
    assert_includes days.today_date_button_class, "bg-accent"
    assert_includes days.current_month_button_class, "bg-background"
    assert_includes days.other_month_button_class, "text-muted-foreground"
  end
end
