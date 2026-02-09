# frozen_string_literal: true

require "test_helper"

class RubyUI::NativeSelectTest < ComponentTest
  def test_render_with_options
    output = phlex do
      RubyUI.NativeSelect do
        RubyUI.NativeSelectOption(value: "") { "Select a fruit" }
        RubyUI.NativeSelectOption(value: "apple") { "Apple" }
        RubyUI.NativeSelectOption(value: "banana") { "Banana" }
      end
    end

    assert_match(/Select a fruit/, output)
    assert_match(/Apple/, output)
    assert_match(/Banana/, output)
    assert_match(/<select/, output)
  end

  def test_render_with_groups
    output = phlex do
      RubyUI.NativeSelect do
        RubyUI.NativeSelectGroup(label: "Fruits") do
          RubyUI.NativeSelectOption(value: "apple") { "Apple" }
          RubyUI.NativeSelectOption(value: "banana") { "Banana" }
        end
        RubyUI.NativeSelectGroup(label: "Vegetables") do
          RubyUI.NativeSelectOption(value: "carrot") { "Carrot" }
        end
      end
    end

    assert_match(/<optgroup/, output)
    assert_match(/Fruits/, output)
    assert_match(/Vegetables/, output)
    assert_match(/Carrot/, output)
  end

  def test_render_with_small_size
    output = phlex do
      RubyUI.NativeSelect(size: :sm) do
        RubyUI.NativeSelectOption(value: "apple") { "Apple" }
      end
    end

    assert_match(/Apple/, output)
    assert_match(/<select/, output)
  end

  def test_render_with_disabled
    output = phlex do
      RubyUI.NativeSelect(disabled: true) do
        RubyUI.NativeSelectOption(value: "apple") { "Apple" }
      end
    end

    assert_match(/disabled/, output)
  end

  def test_render_with_name
    output = phlex do
      RubyUI.NativeSelect(name: "fruit") do
        RubyUI.NativeSelectOption(value: "apple") { "Apple" }
      end
    end

    assert_match(/name="fruit"/, output)
  end
end
