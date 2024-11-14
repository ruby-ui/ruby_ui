# frozen_string_literal: true

require "test_helper"
require_relative "alert_dialog_spec"

class RubyUI::AlertDialogTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def setup
    @spec = RubyUI::AlertDialogSpec.new
  end

  def test_render_with_all_items
    output = phlex_context do
      @spec.spec(self)
    end
    assert_match(/Show dialog/, output)
  end
end
