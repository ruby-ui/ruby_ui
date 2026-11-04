# frozen_string_literal: true

class Views::Docs::Popover < Views::Base
  def view_template
    component = "Popover"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Popover", description: "Displays rich content in a portal, triggered by a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "A click, Enter or Space on the trigger opens the popover; Escape or a click outside closes it, and focus goes back to the trigger unless the click moved it to another control. PopoverTitle names the dialog and PopoverDescription describes it for screen readers.", context: self) do
        <<~RUBY
          Popover do
            PopoverTrigger do
              Button(variant: :outline) { "Open Popover" }
            end
            PopoverContent(align: :start) do
              PopoverHeader do
                PopoverTitle { "Dimensions" }
                PopoverDescription { "Set the dimensions for the layer." }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sides", description: "Content without a PopoverTitle needs aria: {label:} so the dialog has a name. side: places the content around the trigger: :top, :right, :bottom (the default), :left, or the logical :inline_start and :inline_end, which follow the writing direction. side_offset: is the gap in pixels (4 by default). The content flips to the other side when there is no room.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2") do
            [:inline_start, :left, :top, :bottom, :right, :inline_end].each do |side|
              Popover do
                PopoverTrigger do
                  Button(variant: :outline, class: "capitalize") { side.to_s.tr("_", " ") }
                end
                PopoverContent(side: side, class: "w-40", aria: {label: "Popover on \#{side.to_s.tr("_", " ")}"}) do
                  p { "Popover on \#{side.to_s.tr("_", " ")}" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Alignments", description: "align: lines the content up with the trigger's :start, :center (the default) or :end. align_offset: shifts it along that edge.", context: self) do
        <<~RUBY
          div(class: "flex gap-6") do
            [:start, :center, :end].each do |align|
              Popover do
                PopoverTrigger do
                  Button(variant: :outline, size: :sm, class: "capitalize") { align.to_s }
                end
                PopoverContent(align: align, class: "w-40", aria: {label: "Aligned to \#{align}"}) { "Aligned to \#{align}" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With form", context: self) do
        <<~RUBY
          Popover do
            PopoverTrigger do
              Button(variant: :outline) { "Open Popover" }
            end
            PopoverContent(align: :start, class: "w-64") do
              PopoverHeader do
                PopoverTitle { "Dimensions" }
                PopoverDescription { "Set the dimensions for the layer." }
              end
              div(class: "flex flex-col gap-4") do
                div(class: "flex items-center gap-2") do
                  FormFieldLabel(for: "popover-width", class: "w-1/2") { "Width" }
                  Input(id: "popover-width", value: "100%")
                end
                div(class: "flex items-center gap-2") do
                  FormFieldLabel(for: "popover-height", class: "w-1/2") { "Height" }
                  Input(id: "popover-height", value: "25px")
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open on hover", description: "open_on_hover: also opens the popover when the pointer rests on the trigger for delay: milliseconds (300 by default), and closes it close_delay: milliseconds (0 by default) plus a 100 ms grace after the pointer leaves both the trigger and the content, so the pointer can cross the gap onto the content. A click, Enter or Space still opens it, so it stays usable from the keyboard.", context: self) do
        <<~RUBY
          Popover do
            PopoverTrigger(open_on_hover: true, delay: 100, close_delay: 100) do
              Button(variant: :outline) { "Hover me" }
            end
            PopoverContent do
              PopoverHeader do
                PopoverTitle { "Hover popover" }
                PopoverDescription { "Opens while the pointer rests on the trigger." }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "In a dialog", description: "Escape closes the popover first and leaves the dialog open.", context: self) do
        <<~RUBY
          Dialog do
            DialogTrigger do
              Button(variant: :outline) { "Open Dialog" }
            end
            DialogContent do
              DialogHeader do
                DialogTitle { "Popover Example" }
                DialogDescription { "Click the button below to see the popover." }
              end
              Popover do
                PopoverTrigger do
                  Button(variant: :outline, class: "w-fit") { "Open Popover" }
                end
                PopoverContent(align: :start) do
                  PopoverHeader do
                    PopoverTitle { "Popover in Dialog" }
                    PopoverDescription { "This popover appears inside a dialog. Click the button to open it." }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inside a clipping container", description: "The content opens in the top layer, so a container that hides its overflow (a scroll area, a table cell, a card) doesn't clip it.", context: self) do
        <<~RUBY
          div(class: "relative h-24 w-64 overflow-hidden rounded-md border p-4") do
            Popover do
              PopoverTrigger do
                Button(variant: :outline) { "Open Popover" }
              end
              PopoverContent(aria: {label: "Clipping example"}) do
                p { "Not clipped by the container above." }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
