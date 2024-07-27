# frozen_string_literal: true

module PhlexUi
  class AlertDialogPreview < Lookbook::Preview
    # Default AlertDialog
    # ---------------
    def default
      render(TestView.new) do
        AlertDialog do
          AlertDialogTrigger { Button { "Show dialog" } }

          AlertDialogContent do
            AlertDialogHeader do
              AlertDialogTitle { "Are you absolutely sure?" }
              AlertDialogDescription do
                "This action cannot be undone. This will permanently delete your account and remove your data from our servers."
              end
            end

            AlertDialogFooter do
              AlertDialogCancel { "Cancel" }
              AlertDialogAction { "Continue" }
            end
          end
        end
      end
    end
  end
end
