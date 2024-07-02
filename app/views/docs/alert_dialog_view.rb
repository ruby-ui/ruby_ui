# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Alert Dialog", description: "A modal dialog that interrupts the user with important content and expects a response.")

      TypographyH2 { "Usage" }
      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          AlertDialog do
            AlertDialogTrigger do
              Button { "Show dialog" }
            end
            AlertDialogContent do
              AlertDialogHeader do
                AlertDialogTitle { "Are you absolutely sure?" }
                AlertDialogDescription { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
              end
              AlertDialogFooter do
                AlertDialogCancel { "Cancel" }
                AlertDialogAction { "Continue" } # Will probably be a link to a controller action (e.g. delete account)
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "AlertDialogController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/alert_dialog_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "AlertDialog", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogContent", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogHeader", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogTitle", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogDescription", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogFooter", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/footer.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogCancel", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/cancel.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AlertDialogAction", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/action.rb", built_using: :phlex)
    ]
  end
end
