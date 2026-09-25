# frozen_string_literal: true

require "test_helper"

class RubyUI::SpinnerTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI::Spinner()
    end

    assert_match(/<svg/, output)
    assert_match(/viewbox="0 0 24 24"/, output)
    assert_match(/stroke="currentColor"/, output)
    assert_match(/role="status"/, output)
    assert_match(/aria-label="Loading"/, output)
    assert_match(/data-slot="spinner"/, output)
    assert_match(/size-4/, output)
    assert_match(/animate-spin/, output)
  end

  def test_render_with_custom_size
    output = phlex do
      RubyUI::Spinner(class: "size-6 text-blue-500")
    end

    assert_match(/size-6/, output)
    refute_match(/size-4/, output)
    assert_match(/text-blue-500/, output)
    assert_match(/animate-spin/, output)
  end

  def test_render_with_custom_label
    output = phlex do
      RubyUI::Spinner(label: "Saving")
    end

    assert_match(/aria-label="Saving"/, output)
    refute_match(/Loading/, output)
  end

  def test_render_decorative_when_label_is_nil
    output = phlex do
      RubyUI::Spinner(label: nil)
    end

    assert_match(/aria-hidden="true"/, output)
    refute_match(/role="status"/, output)
    refute_match(/aria-label/, output)
  end

  def test_render_decorative_when_label_is_blank
    ["", "  "].each do |label|
      output = phlex do
        RubyUI::Spinner(label: label)
      end

      assert_match(/aria-hidden="true"/, output)
      refute_match(/role="status"/, output)
      refute_match(/aria-label/, output)
    end
  end

  def test_render_with_arbitrary_attrs
    output = phlex do
      RubyUI::Spinner(data: {icon: "inline-start"}, id: "save-spinner")
    end

    assert_match(/data-icon="inline-start"/, output)
    assert_match(/data-slot="spinner"/, output)
    assert_match(/id="save-spinner"/, output)
  end
end
