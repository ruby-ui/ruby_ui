# frozen_string_literal: true

require "test_helper"

class RubyUI::CalendarTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Input(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "ruby_ui--input")
      RubyUI.Calendar(input_id: "#date", class: "rounded-md border shadow")
    end

    assert_match(/Select a date/, output)
  end
end
