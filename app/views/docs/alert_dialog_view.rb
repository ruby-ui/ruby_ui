# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Alert Dialog" }
        render Typography::P.new { "A modal dialog that interrupts the user with important content and expects a response." }
      end

      render Docs::Component.new(title: "Default") do
        render AlertDialog.new do |alert_dialog|
          render AlertDialogTrigger.new do
            render Button.new { "Show dialog" }
          end
          render AlertDialogContent.new
        end
      end
    end
  end
end
