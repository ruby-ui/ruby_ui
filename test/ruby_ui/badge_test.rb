# frozen_string_literal: true

require 'test_helper'

module RubyUI
  class BadgeTest < ComponentTest
    def test_render_with_all_items
      output = phlex do
        RubyUI.Badge { 'Badge' }
      end

      assert_match(/Badge/, output)
    end
  end
end
