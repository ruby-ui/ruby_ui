# frozen_string_literal: true

require "test_helper"

class RubyUI::AspectRatioTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.AspectRatio(ratio: "16/9") do |aspect|
        aspect.img(
          alt: "Placeholder",
          loading: "lazy",
          src: "https://avatars.githubusercontent.com/u/246692?v=4"
        )
      end
    end

    assert_match(/Placeholder/, output)
  end

  def test_renders_a_single_div_with_data_slot_and_ratio
    output = phlex { RubyUI.AspectRatio(ratio: "16/9") { "content" } }

    assert_equal 1, output.scan("<div").size
    assert_match(/data-slot="aspect-ratio"/, output)
    assert_match(/style="--ratio: 1\.7777777777777777;"/, output)
    assert_match(/class="relative aspect-\(--ratio\)"/, output)
  end

  def test_has_no_default_background_or_image_styles
    output = phlex { RubyUI.AspectRatio(ratio: "1/1") { "content" } }

    refute_match(/bg-muted/, output)
    refute_match(/\[&>img\]/, output)
  end

  def test_user_attrs_land_on_the_root
    output = phlex { RubyUI.AspectRatio(ratio: "4/3", id: "hero", class: "rounded-lg bg-muted") { "content" } }

    assert_match(/<div data-slot="aspect-ratio"[^>]* id="hero"[^>]*>content<\/div>/, output)
    assert_match(/class="relative aspect-\(--ratio\) rounded-lg bg-muted"/, output)
  end

  def test_user_style_is_appended_to_the_ratio
    output = phlex { RubyUI.AspectRatio(ratio: "1/1", style: "color: red;") { "content" } }

    assert_match(/style="--ratio: 1\.0; color: red;"/, output)
  end

  def test_user_style_hash_is_merged_with_the_ratio
    output = phlex { RubyUI.AspectRatio(ratio: "1/1", style: {color: "red"}) { "content" } }

    assert_match(/style="--ratio: 1\.0; color: red;"/, output)
  end

  def test_accepts_numeric_ratio
    output = phlex { RubyUI.AspectRatio(ratio: 1.5) { "content" } }

    assert_match(/--ratio: 1\.5;/, output)
  end

  def test_keeps_decimal_parts_of_a_string_ratio
    output = phlex { RubyUI.AspectRatio(ratio: "2.4/1") { "content" } }

    assert_match(/--ratio: 2\.4;/, output)
  end

  def test_defaults_to_16_9
    output = phlex { RubyUI.AspectRatio { "content" } }

    assert_match(/--ratio: 1\.7777777777777777;/, output)
  end

  def test_aspect_ratio_is_a_deprecated_alias_of_ratio
    output = nil
    _, warnings = with_deprecation_warnings do
      output = phlex { RubyUI.AspectRatio(aspect_ratio: "4/3") { "content" } }
    end

    assert_match(/--ratio: 1\.3333333333333333;/, output)
    assert_match(/`aspect_ratio:` is deprecated, use `ratio:`/, warnings)
  end

  def test_rejects_invalid_ratios
    ["16:9", "abc", "16/0", "0/9", 0, -1, []].each do |value|
      assert_raises(ArgumentError) { RubyUI::AspectRatio.new(ratio: value) }
    end
  end

  private

  def with_deprecation_warnings(&)
    previous = Warning[:deprecated]
    Warning[:deprecated] = true
    capture_io(&)
  ensure
    Warning[:deprecated] = previous
  end
end
