# frozen_string_literal: true

require "test_helper"
require "cgi"

class RubyUI::DatePickerTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.DatePicker(id: "event-date", name: "event[date]", value: "2026-05-15")
    end

    root = tag(output, 'data-controller="ruby-ui--date-picker"')
    assert_equal "group", root["role"]
    assert_equal "field", root["data-slot"]
    assert_equal "#event-date-popover", root["data-ruby-ui--date-picker-ruby-ui--popover-outlet"]
    assert_equal "#event-date-calendar", root["data-ruby-ui--date-picker-ruby-ui--calendar-outlet"]

    label = tag(output, "<label")
    assert_equal "event-date", label["for"]
    assert_equal "field-label", label["data-slot"]
    assert_match(%r{for="event-date">Select a date</label>}, output)

    input = tag(output, 'id="event-date"', name: "input")
    assert_equal "text", input["type"]
    assert_equal "event[date]", input["name"]
    assert_equal "2026-05-15", input["value"]
    assert_equal "input-group-control", input["data-slot"]
    assert_equal "ruby-ui--calendar-input", input["data-controller"]
    assert_includes input["data-action"], "keydown->ruby-ui--date-picker#inputKeydown"
    assert_includes input["data-action"], "input->ruby-ui--date-picker#syncCalendar"
    assert_includes input["data-action"], "input->ruby-ui--form-field#onInput"
    assert_match(/role="group" data-slot="input-group"><input/, output)

    calendar = tag(output, 'data-controller="ruby-ui--calendar"')
    assert_equal "event-date-calendar", calendar["id"]
    assert_equal "#event-date", calendar["data-ruby-ui--calendar-ruby-ui--calendar-input-outlet"]
  end

  def test_trigger_is_an_icon_button_wired_to_the_popup
    output = phlex { RubyUI.DatePicker(id: "event-date") }

    popover = tag(output, 'data-controller="ruby-ui--popover"')
    assert_equal "event-date-popover", popover["id"]
    assert_equal({"trigger" => "click", "placement" => "bottom-end"}, JSON.parse(popover["data-ruby-ui--popover-options-value"]))

    button = tag(output, "<button")
    assert_equal "button", button["type"]
    assert_equal "Select date", button["aria-label"]
    assert_equal "dialog", button["aria-haspopup"]
    assert_equal "false", button["aria-expanded"]
    refute button.key?("aria-controls"), "aria-controls is set by the controller while open"
    assert_equal "trigger", button["data-ruby-ui--date-picker-target"]
    assert_equal "input-group-button", button["data-slot"]

    content = tag(output, 'data-ruby-ui--popover-target="content"')
    assert_equal "event-date-content", content["id"]
    assert_equal "dialog", content["role"]
    assert_equal "Choose date", content["aria-label"]
    assert_equal "popover-content", content["data-slot"]
    assert_equal "click->ruby-ui--date-picker#pick", content["data-action"]
    assert_includes content["class"].split, "p-0"
    refute_includes content["class"].split, "p-1"
  end

  def test_render_without_label
    output = phlex do
      RubyUI.DatePicker(id: "event-date", label: nil)
    end

    refute_match(/<label/, output)
    assert_match(/id="event-date"/, output)
  end

  def test_attrs_reach_their_parts
    output = phlex do
      RubyUI.DatePicker(
        id: "event-date",
        class: "max-w-xs",
        popover_options: {placement: "top-start"},
        input_attrs: {required: true},
        trigger_attrs: {aria: {label!: "Choose event date"}},
        content_attrs: {class: "w-72"}
      )
    end

    assert_includes tag(output, 'data-controller="ruby-ui--date-picker"')["class"].split, "max-w-xs"
    assert_equal "top-start", JSON.parse(tag(output, 'data-controller="ruby-ui--popover"')["data-ruby-ui--popover-options-value"])["placement"]
    assert tag(output, 'id="event-date"', name: "input").key?("required")
    assert_equal "Choose event date", tag(output, 'data-ruby-ui--date-picker-target="trigger"')["aria-label"]
    assert_includes tag(output, 'data-ruby-ui--popover-target="content"')["class"].split, "w-72"
  end

  def test_selected_date_is_written_in_date_format
    {
      "yyyy-MM-dd" => "2026-03-12",
      "dd/MM/yyyy" => "12/03/2026",
      "PPPP" => "Thursday, March 12th, 2026",
      "MMMM do, yyyy" => "March 12th, 2026"
    }.each do |format, expected|
      [Date.new(2026, 3, 12), "2026-03-12"].each do |selected|
        output = phlex { RubyUI.DatePicker(id: "d", selected_date: selected, date_format: format) }

        assert_equal expected, tag(output, 'id="d"', name: "input")["value"], "#{format} / #{selected.inspect}"
      end
    end
  end

  def test_explicit_value_is_kept_as_given
    output = phlex { RubyUI.DatePicker(id: "d", value: "2026-03-12", date_format: "PPPP") }

    assert_equal "2026-03-12", tag(output, 'id="d"', name: "input")["value"]
  end

  def test_calendar_outlet_follows_a_custom_calendar_id
    output = phlex { RubyUI.DatePicker(id: "event-date", calendar_attrs: {id: "event-calendar"}) }

    assert_equal "event-calendar", tag(output, 'data-controller="ruby-ui--calendar"')["id"]
    assert_equal "#event-calendar", tag(output, 'data-controller="ruby-ui--date-picker"')["data-ruby-ui--date-picker-ruby-ui--calendar-outlet"]
  end

  def test_trigger_keeps_a_single_slot_with_caller_data
    output = phlex { RubyUI.DatePicker(id: "event-date", trigger_attrs: {data: {testid: "open-calendar"}}) }
    button = tag(output, "<button")

    assert_equal "input-group-button", button["data-slot"]
    assert_equal "open-calendar", button["data-testid"]
    assert_equal "trigger", button["data-ruby-ui--date-picker-target"]
  end

  private

  # Attributes of the first opening tag (of the given element name) whose
  # source contains needle.
  def tag(output, needle, name: nil)
    source = output.scan(/<[a-z]+(?:[^>"]|"[^"]*")*>/).find { |t| t.include?(needle) && (name.nil? || t.start_with?("<#{name}")) }
    flunk "no tag with #{needle}" unless source
    source.scan(/([a-zA-Z_:-]+)(?:="([^"]*)")?/).drop(1).to_h { |k, v| [k, v && CGI.unescapeHTML(v)] }
  end
end
