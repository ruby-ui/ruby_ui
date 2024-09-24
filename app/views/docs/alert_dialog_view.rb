# frozen_string_literal: true

class Docs::AlertDialogView < ApplicationView
  def view_template
    component = "AlertDialog"
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

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
