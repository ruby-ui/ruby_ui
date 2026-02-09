# frozen_string_literal: true

require "test_helper"

class RubyUI::NativeSelectTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.NativeSelect(name: "department") do
        RubyUI.NativeSelectOption(value: "") { "Select a department" }
        RubyUI.NativeSelectGroup(label: "Engineering") do
          RubyUI.NativeSelectOption(value: "frontend") { "Frontend" }
          RubyUI.NativeSelectOption(value: "backend") { "Backend" }
        end
        RubyUI.NativeSelectGroup(label: "Sales") do
          RubyUI.NativeSelectOption(value: "account_executive") { "Account Executive" }
        end
      end
    end

    assert_match(/Frontend/, output)
    assert_match('name="department"', output)
  end
end
