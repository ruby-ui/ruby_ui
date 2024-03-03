# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Alert Dialog", description: "A modal dialog that interrupts the user with important content and expects a response.")

      render PhlexUI::Typography::H2.new { "Usage" }
      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::AlertDialog.new do
            render PhlexUI::AlertDialog::Trigger.new do
              render PhlexUI::Button.new { "Show dialog" }
            end
            render PhlexUI::AlertDialog::Content.new do
              render PhlexUI::AlertDialog::Header.new do
                render PhlexUI::AlertDialog::Title.new { "Are you absolutely sure?" }
                render PhlexUI::AlertDialog::Description.new { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
              end
              render PhlexUI::AlertDialog::Footer.new do
                render PhlexUI::AlertDialog::Cancel.new { "Cancel" }
                render PhlexUI::AlertDialog::Action.new { "Continue" } # Will probably be a link to a controller action (e.g. delete account)
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
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Header", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Title", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Description", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Footer", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/footer.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Cancel", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/cancel.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::AlertDialog::Action", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert_dialog/action.rb", built_using: :phlex)
    ]
  end
end
