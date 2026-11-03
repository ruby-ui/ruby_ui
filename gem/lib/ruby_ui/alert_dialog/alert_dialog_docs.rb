# frozen_string_literal: true

class Views::Docs::AlertDialog < Views::Base
  def view_template
    component = "AlertDialog"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Alert Dialog", description: "A modal dialog that interrupts the user with important content and expects a response.")

      Heading(level: 2) { "Usage" }
      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          AlertDialog do
            AlertDialogTrigger do
              Button(variant: :outline) { "Show dialog" }
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

      render Docs::VisualCodeExample.new(title: "Small", description: "Pass size: :sm to AlertDialogContent for a narrower dialog with the footer buttons side by side.", context: self) do
        <<~RUBY
          AlertDialog do
            AlertDialogTrigger do
              Button(variant: :outline) { "Show dialog" }
            end
            AlertDialogContent(size: :sm) do
              AlertDialogHeader do
                AlertDialogTitle { "Allow accessory to connect?" }
                AlertDialogDescription { "Do you want to allow the USB accessory to connect to this device?" }
              end
              AlertDialogFooter do
                AlertDialogCancel { "Don't allow" }
                AlertDialogAction { "Allow" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Media", description: "AlertDialogMedia shows an icon next to the title (above it on small screens or with size: :sm).", context: self) do
        <<~RUBY
          AlertDialog do
            AlertDialogTrigger do
              Button(variant: :destructive) { "Delete chat" }
            end
            AlertDialogContent do
              AlertDialogHeader do
                AlertDialogMedia(class: "bg-destructive/10 text-destructive") do
                  svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
                    s.path(d: "M3 6h18")
                    s.path(d: "M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6")
                    s.path(d: "M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2")
                  end
                end
                AlertDialogTitle { "Delete chat?" }
                AlertDialogDescription { "This will permanently delete this chat conversation." }
              end
              AlertDialogFooter do
                AlertDialogCancel { "Cancel" }
                AlertDialogAction(variant: :destructive) { "Delete" }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Inside a form" }
      p { "The dialog renders in place, and HTML does not allow nested forms: a button_to inside AlertDialogAction loses its own form and submits the outer one instead. Render the AlertDialog after the form, or give the action button a form attribute that points to a form elsewhere on the page." }

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
