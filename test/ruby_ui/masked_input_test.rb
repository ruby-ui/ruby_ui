# frozen_string_literal: true

require "test_helper"

class RubyUI::MaskedInputTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render
    output = phlex_context do
      RubyUI.MaskedInput(data: {maska: "#####-###"})
    end

    assert_match(/<input type="text"/, output)
    assert_match(/data-controller="ruby-ui--masked-input"/, output)
    assert_match(/data-maska="#####-###"/, output)
  end
end
