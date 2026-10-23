# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertDialogTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
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

  # Every modal shares shadcn's overlay: black at 10% in both themes, blurred only where backdrop-filter is supported.
  def test_content_uses_the_shared_modal_overlay
    output = phlex do
      RubyUI.AlertDialogContent { "Content" }
    end

    assert_includes output, "bg-black/10"
    assert_includes output, "supports-backdrop-filter:backdrop-blur-xs"
    refute_match(/bg-background\/80|bg-black\/80|backdrop-blur-sm/, output)
  end
end
