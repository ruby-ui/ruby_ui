# frozen_string_literal: true

require "test_helper"

class RubyUI::MaskedInputTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.MaskedInput(data: {maska: "#####-###"})
    end

    assert_match(/<input type="text"/, output)
    assert_match(/data-controller="ruby-ui--masked-input"/, output)
    assert_match(/data-maska="#####-###"/, output)
    refute_match(/<input type="hidden"/, output)
  end

  def test_render_with_save_unmasked
    output = phlex do
      RubyUI.MaskedInput(save_unmasked: true, name: "agency", value: "0000", data: {maska: "####"})
    end

    assert_match(/<input type="text"/, output)
    assert_match(/<input type="hidden" name="agency" value="0000"/, output)
    assert_match(/data-maska="####"/, output)
    assert_match(/data-controller="ruby-ui--masked-input"/, output)
  end
end
