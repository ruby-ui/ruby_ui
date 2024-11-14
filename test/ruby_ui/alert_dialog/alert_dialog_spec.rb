# frozen_string_literal: true

class RubyUI::AlertDialogSpec
  def spec(context)
    context.instance_exec do
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
  end
end
