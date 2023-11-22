# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Alert Dialog" }
        render PhlexUI::Typography::P.new { "A modal dialog that interrupts the user with important content and expects a response." }
      end

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

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
