# frozen_string_literal: true

require "test_helper"

class RubyUI::CalendarTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Input(placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "ruby-ui--input")
      RubyUI.Calendar(input_id: "#date", class: "rounded-md border shadow")
    end

    assert_match(/Select a date/, output)
  end

  def test_render_with_min_date
    output = phlex do
      RubyUI.Calendar(min_date: "2026-05-07")
    end

    assert_match(/data-ruby-ui--calendar-min-date-value="2026-05-07"/, output)
    assert_match(/data-ruby-ui--calendar-target="disabledDateTemplate"/, output)
    assert_match(/disabled/, output)
  end

  def test_render_grid_semantics
    output = phlex { RubyUI.Calendar }

    assert_match(/<table role="grid"[^>]*data-action="keydown->ruby-ui--calendar#navigate"/, output)
    assert_match(/<nav aria-label="Navigation bar"/, output)
    assert_match(/role="status" aria-live="polite"/, output)
    assert_match(/<thead aria-hidden="true">/, output)
    assert_match(/<td [^>]*role="gridcell" aria-selected="true">/, output)
    assert_match(/aria-label="\{\{label\}\}"/, output)
    assert_match(/tabindex="\{\{tabindex\}\}"/, output)
    refute_match(/<button[^>]*role="gridcell"/, output)
  end

  def test_week_starts_on_sunday_by_default
    output = phlex { RubyUI.Calendar }

    assert_match(/data-ruby-ui--calendar-week-starts-on-value="0"/, output)
    assert_match(/aria-label="Sunday">Su<\/th><th [^>]*aria-label="Monday"/, output)
  end

  def test_week_starts_on_monday
    output = phlex { RubyUI.Calendar(week_starts_on: :monday) }

    assert_match(/data-ruby-ui--calendar-week-starts-on-value="1"/, output)
    assert_match(/<tr class="flex"><th [^>]*aria-label="Monday"/, output)
    assert_match(/aria-label="Saturday">Sa<\/th><th [^>]*aria-label="Sunday"/, output)
  end

  def test_week_starts_on_rejects_unknown_day
    assert_raises(ArgumentError) { RubyUI::Calendar.new(week_starts_on: :someday) }
  end
end
