# frozen_string_literal: true

require 'test_helper'

module RubyUI
  class MaskedInputTest < ComponentTest
    def test_render
      output = phlex do
        RubyUI.MaskedInput(data: { maska: '#####-###' })
      end

      assert_match(/<input type="text"/, output)
      assert_match(/data-controller="ruby-ui--masked-input"/, output)
      assert_match(/data-maska="#####-###"/, output)
    end
  end
end
