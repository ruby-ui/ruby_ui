# frozen_string_literal: true

require "test_helper"

class RubyUI::SelectTest < ComponentTest
  def test_render_with_all_items
    people = [
      ["John Doe", 1],
      ["Jane Doe", 2],
      ["Sam Smith", 3]
    ]

    output = phlex do
      RubyUI.Select do
        RubyUI.SelectInput(name: "NAME")
        RubyUI.SelectTrigger do
          RubyUI.SelectValue(placeholder: "Placeholder")
        end
        RubyUI.SelectContent(outlet_id: "1") do
          RubyUI.SelectGroup do
            people.each do |person|
              RubyUI.SelectItem(value: person[1]) { person[0] }
            end
          end
        end
      end
    end

    assert_match(/John/, output)
    assert_match('name="NAME"', output)
  end

  def test_select_value_renders_placeholder_when_block_returns_nil
    output = phlex do
      RubyUI.SelectValue(placeholder: "Placeholder") do
        nil
      end
    end

    assert_match(/Placeholder/, output)
  end
end
