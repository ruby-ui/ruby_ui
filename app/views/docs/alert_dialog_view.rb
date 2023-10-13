# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Alert Dialog" }
        render Typography::P.new { "A modal dialog that interrupts the user with important content and expects a response." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render AlertDialog.new do |alert_dialog|
          render AlertDialogTrigger.new do
            render Button.new { "Show dialog" }
          end
          render AlertDialogContent.new() do
            render AlertDialogHeader.new do
              render AlertDialogTitle.new { "Are you absolutely sure?" }
              render AlertDialogDescription.new { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
            end
            render AlertDialogFooter.new do
              render AlertDialogCancel.new { "Cancel" }
              render AlertDialogAction.new { "Continue" } # Will probably be a link to a controller action (e.g. delete account)
            end
          end
        end
      end
    end
  end
end
