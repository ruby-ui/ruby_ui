# frozen_string_literal: true

require "test_helper"

class RubyUI::DatePickerTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.DatePicker(id: "event-date", name: "event[date]", value: "2026-05-15")
    end

    assert_match(/<label for="event-date">Select a date<\/label>/, output)
    assert_match(/<input type="string"/, output)
    assert_match(/id="event-date"/, output)
    assert_match(/name="event\[date\]"/, output)
    assert_match(/value="2026-05-15"/, output)
    assert_match(/data-controller="ruby-ui--calendar-input"/, output)
    assert_match(/data-controller="ruby-ui--popover"/, output)
    assert_match(/data-controller="ruby-ui--calendar"/, output)
    assert_match(/data-ruby-ui--calendar-ruby-ui--calendar-input-outlet="#event-date"/, output)
  end

  def test_render_without_label
    output = phlex do
      RubyUI.DatePicker(id: "event-date", label: nil)
    end

    refute_match(/<label/, output)
    assert_match(/id="event-date"/, output)
  end
end
