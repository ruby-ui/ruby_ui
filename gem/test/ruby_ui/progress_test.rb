# frozen_string_literal: true

require "test_helper"

class RubyUI::ProgressTest < ComponentTest
  def test_render
    output = phlex { RubyUI::Progress(value: 50) }

    assert_match(/role="progressbar"/, output)
    assert_match(/aria-valuemin="0"/, output)
    assert_match(/aria-valuemax="100"/, output)
    assert_match(/aria-valuenow="50"/, output)
    assert_match(/aria-valuetext="50%"/, output)
    assert_match(/data-slot="progress"/, output)
    assert_match(/data-slot="progress-track"/, output)
    assert_match(/data-slot="progress-indicator"/, output)
    assert_match(/width: 50%;/, output)
    assert_equal 3, output.scan("data-progressing").size
  end

  def test_vega_classes
    output = phlex { RubyUI::Progress(value: 50) }

    assert_match(/class="flex flex-wrap gap-3"/, output)
    assert_match(/class="relative flex h-1.5 w-full items-center overflow-x-hidden rounded-full bg-muted"/, output)
    assert_match(/class="h-full bg-primary transition-all"/, output)
  end

  def test_fractional_value_keeps_decimals_and_rounds_text
    output = phlex { RubyUI::Progress(value: 33.5) }

    assert_match(/aria-valuenow="33.5"/, output)
    assert_match(/aria-valuetext="34%"/, output)
  end

  def test_value_is_clamped
    output = phlex { RubyUI::Progress(value: 150) }

    assert_match(/aria-valuenow="100"/, output)
    assert_match(/data-complete/, output)
    refute_match(/data-progressing/, output)
  end

  def test_min_and_max
    output = phlex { RubyUI::Progress(value: 3, min: 1, max: 5) }

    assert_match(/aria-valuemin="1"/, output)
    assert_match(/aria-valuemax="5"/, output)
    assert_match(/aria-valuenow="3"/, output)
    assert_match(/aria-valuetext="50%"/, output)
    assert_match(/width: 50%;/, output)
  end

  def test_nil_value_is_indeterminate
    output = phlex { RubyUI::Progress(value: nil) }

    refute_match(/aria-valuenow/, output)
    assert_match(/aria-valuetext="indeterminate progress"/, output)
    assert_equal 3, output.scan("data-indeterminate").size
    refute_match(/width:/, output)
  end

  def test_valuetext_can_be_replaced
    output = phlex { RubyUI::Progress(value: 3, max: 7, aria: {valuetext: "Step 3 of 7"}) }

    assert_match(/aria-valuetext="Step 3 of 7"/, output)
  end

  def test_flat_valuetext_replaces_the_default
    output = phlex { RubyUI::Progress(value: 3, max: 7, aria_valuetext: "Step 3 of 7") }

    assert_equal 1, output.scan("aria-valuetext").size
    assert_match(/aria-valuetext="Step 3 of 7"/, output)
  end

  def test_each_label_gets_its_own_id
    output = phlex do
      RubyUI::Progress(value: 50) do
        RubyUI::ProgressLabel { "First" }
        RubyUI::ProgressLabel { "Second" }
      end
    end

    ids = output.scan(/<span[^>]* id="([^"]+)"/).flatten
    assert_equal 2, ids.uniq.size
    assert_match(/aria-labelledby="#{ids.last}"/, output)
  end

  def test_value_block_gets_the_value_before_clamping
    output = phlex { RubyUI::Progress(value: 150) { RubyUI::ProgressValue { |formatted, value| "#{formatted} #{value}" } } }

    assert_match(/100% 150</, output)
  end

  def test_label_names_the_progressbar
    output = phlex do
      RubyUI::Progress(value: 56) do
        RubyUI::ProgressLabel { "Upload progress" }
        RubyUI::ProgressValue()
      end
    end

    label = output[/<span[^>]*data-slot="progress-label"[^>]*>/]
    label_id = label[/ id="([^"]+)"/, 1]
    assert label_id, "label has an id"
    assert_match(/role="presentation"/, label)
    root = output[/<div[^>]*role="progressbar"[^>]*>/]
    assert_match(/aria-labelledby="#{label_id}"/, root)
    value = output[/<span[^>]*data-slot="progress-value"[^>]*>[^<]*<\/span>/]
    assert_match(/aria-hidden="true"/, value)
    assert_match(/>56%<\/span>/, value)
    assert_operator output.index("progress-label"), :<, output.index("progress-track")
  end

  def test_no_labelledby_without_label
    output = phlex { RubyUI::Progress(value: 10) }

    refute_match(/aria-labelledby/, output)
  end

  def test_label_keeps_given_id
    output = phlex { RubyUI::Progress(value: 10) { RubyUI::ProgressLabel(id: "upload") { "Upload" } } }

    assert_match(/aria-labelledby="upload"/, output)
    assert_match(/id="upload"/, output)
  end

  def test_value_block
    output = phlex do
      RubyUI::Progress(value: 3, max: 6) do
        RubyUI::ProgressValue { |formatted, value| "#{value.to_i} of 6 (#{formatted})" }
      end
    end

    assert_match(/3 of 6 \(50%\)/, output)
  end
end
