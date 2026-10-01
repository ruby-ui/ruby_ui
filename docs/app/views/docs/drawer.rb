# frozen_string_literal: true

class Views::Docs::Drawer < Views::Base
  def view_template
    component = "Drawer"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Drawer", description: "A bottom sheet you drag between snap points and swipe down to close. It is built on the native <dialog> element and CSS scroll-snap and needs no JavaScript packages.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "The drawer opens at 60% of the viewport. Drag the handle up and it rests at 92%. Drag it down past the lowest snap point, or flick it down, and it closes.", context: self) do
        <<~RUBY
          Drawer do
            DrawerTrigger do
              Button(variant: :outline) { "Open Drawer" }
            end
            DrawerContent do
              DrawerHeader do
                DrawerTitle { "Edit profile" }
                DrawerDescription { "Make changes to your profile here. Click save when you're done." }
              end
              DrawerMiddle do
                label { "Name" }
                Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                label { "Email" }
                Input(placeholder: "joel@drapper.me")
              end
              DrawerFooter do
                Button(type: "submit", class: "w-full") { "Save" }
                DrawerClose do
                  Button(variant: :outline, class: "w-full") { "Cancel" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Snap points", description: "snap_points lists the heights the panel can rest at, in shadcn's units: up to 1 is a fraction of the viewport, above 1 is pixels, and a string is any CSS length. initial is the index of the one it opens at, and a flick moves to the next snap point in its direction.", context: self) do
        <<~RUBY
          Drawer do
            DrawerTrigger do
              Button(variant: :outline) { "Open at 35%" }
            end
            DrawerContent(snap_points: [0.35, 0.7, 1]) do
              DrawerHeader do
                DrawerTitle { "Snap points" }
                DrawerDescription { "Rests at 35%, 70% or 100% of the viewport." }
              end
              DrawerMiddle do
                div(class: "space-y-3") do
                  12.times { div(class: "h-12 rounded-md bg-muted") }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Non-modal", description: "With modal: false there is no scrim and the page behind stays usable, the same as shadcn's modal={false}.", context: self) do
        <<~RUBY
          Drawer do
            DrawerTrigger do
              Button(variant: :outline) { "Open non-modal" }
            end
            DrawerContent(modal: false, snap_points: [0.4]) do
              DrawerHeader do
                DrawerTitle { "Now playing" }
                DrawerDescription { "No scrim, so the page behind stays interactive." }
              end
              DrawerFooter do
                DrawerClose do
                  Button(variant: :outline, class: "w-full") { "Close" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Non-dismissible", description: "With dismissible: false, clicking the scrim, pressing Escape and swiping the drawer down do nothing. Only DrawerClose closes it.", context: self) do
        <<~RUBY
          Drawer do
            DrawerTrigger do
              Button(variant: :outline) { "Open non-dismissible" }
            end
            DrawerContent(dismissible: false, snap_points: [0.45]) do
              DrawerHeader do
                DrawerTitle { "Delete account?" }
                DrawerDescription { "This cannot be undone. Choose one of the options below." }
              end
              DrawerFooter do
                DrawerClose do
                  Button(variant: :destructive, class: "w-full") { "Delete" }
                end
                DrawerClose do
                  Button(variant: :outline, class: "w-full") { "Keep my account" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom swipe handle", description: "handle: false leaves the handle out. Render DrawerSwipeHandle yourself to restyle it or put it somewhere else.", context: self) do
        <<~RUBY
          Drawer do
            DrawerTrigger do
              Button(variant: :outline) { "Open with a custom handle" }
            end
            DrawerContent(handle: false, snap_points: ["24rem"]) do
              DrawerSwipeHandle(class: "w-20 bg-primary")
              DrawerHeader do
                DrawerTitle { "Custom handle" }
                DrawerDescription { "Wider, in the primary color, and the drawer opens 24rem tall." }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Styling and events" }
      p(class: "text-muted-foreground text-sm leading-relaxed") { "The panel carries data-snap-points when the drawer has snap points, data-expanded once it reaches the largest one and data-swiping while a drag is in flight, so each state can be styled with a data-* variant. Drawer fires opened, snap and closed events on its element, and the snap event's detail names the index the panel came to rest at. The open dialog lives under <body>, out of reach of the controllers on the page, so listen on Drawer rather than on DrawerContent." }

      div(class: "rounded-md border bg-muted/30 p-4 mt-2") do
        Codeblock(<<~RUBY, syntax: :ruby)
          Drawer(data: {action: "ruby-ui--drawer:snap->player#trackSnap"}) do
            DrawerTrigger { Button { "Now playing" } }
            DrawerContent(class: "data-expanded:rounded-none") do
              # ...
            end
          end
        RUBY
      end

      Heading(level: 2) { "Drawer or Sheet?" }
      p(class: "text-muted-foreground text-sm leading-relaxed") { "Sheet slides a panel in from any edge and leaves it there. Drawer is a bottom sheet: you drag it between snap points by the handle and swipe it down to close it. The modal variant is a native <dialog> opened with showModal(), so the browser provides the focus trap, aria-modal and the inert page. Drawer only comes up from the bottom edge. There is no equivalent of shadcn's swipeDirection for the other sides." }

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
