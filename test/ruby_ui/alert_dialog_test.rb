# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertDialogTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.AlertDialog do
        RubyUI.AlertDialogTrigger do
          RubyUI.Button { "Show dialog" }
        end
        RubyUI.AlertDialogContent do
          RubyUI.AlertDialogHeader do
            RubyUI.AlertDialogTitle { "Are you absolutely sure?" }
            RubyUI.AlertDialogDescription { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
          end
          RubyUI.AlertDialogFooter do
            RubyUI.AlertDialogCancel { "Cancel" }
            RubyUI.AlertDialogAction { "Continue" }
          end
        end
      end
    end

    assert_match(/Show dialog/, output)
  end
end
