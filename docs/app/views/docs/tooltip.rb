# frozen_string_literal: true

class Views::Docs::Tooltip < Views::Base
  def view_template
    component = "Tooltip"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Tooltip", description: "A popup that displays information related to an element when the element receives keyboard focus or the mouse hovers over it.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "The tooltip opens while the pointer rests on the trigger or when the trigger gets keyboard focus. The pointer can move onto the tooltip; it closes when the pointer leaves both, on blur, on Escape, or when the trigger is pressed. The trigger's button is described by the tooltip (aria-describedby).", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger do
              Button(variant: :outline) { "Show Tooltip" }
            end
            TooltipContent do
              p { "Add to library" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sides", description: "side: places the tooltip around the trigger: :top (the default), :right, :bottom, :left, or the logical :inline_start and :inline_end, which follow the writing direction. side_offset: is the gap in pixels (4 by default); align: (:start, :center, :end) and align_offset: line it up along that edge. It flips to the other side when there is no room.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2") do
            [:inline_start, :left, :top, :bottom, :right, :inline_end].each do |side|
              Tooltip do
                TooltipTrigger do
                  Button(variant: :outline, class: "capitalize") { side.to_s.tr("_", " ") }
                end
                TooltipContent(side: side) do
                  p { "Add to library" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With icon", description: "An icon-only trigger still needs an accessible name: the tooltip describes the button, it doesn't name it.", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger do
              Button(variant: :ghost, icon: true) do
                bookmark_icon
                span(class: "sr-only") { "Bookmark" }
              end
            end
            TooltipContent do
              p { "Add to library" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Long content", description: "Long text wraps at 20rem.", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger do
              Button(variant: :outline) { "Show Tooltip" }
            end
            TooltipContent do
              plain "To learn more about how this works, check out the docs. If you have any questions, please reach out to us."
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled button", description: "A disabled button gets no pointer events, so the wrapper still opens the tooltip on hover.", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger do
              Button(variant: :outline, disabled: true) { "Disabled" }
            end
            TooltipContent do
              p { "This feature is currently unavailable" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With keyboard shortcut", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger do
              Button(variant: :outline, size: :sm) { "Save" }
            end
            TooltipContent do
              plain "Save Changes"
              ShortcutKey { "S" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Delay and click", description: "delay: waits that many milliseconds of pointer rest before opening (0 by default), close_delay: waits before closing (0 by default, plus a 100 ms grace to cross onto the tooltip). close_on_click: false keeps it open when the trigger is pressed.", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger(delay: 500, close_on_click: false) do
              Button(variant: :outline) { "Hover and wait" }
            end
            TooltipContent do
              p { "Opened after 500 ms" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled tooltip", description: "disabled: true keeps the tooltip from opening. open: true renders it open on load. Changing the data-ruby-ui--tooltip-open-value or -disabled-value attribute later opens, closes or disables it, and every change dispatches ruby-ui--tooltip:change with detail.open.", context: self) do
        <<~RUBY
          Tooltip(disabled: true) do
            TooltipTrigger do
              Button(variant: :outline) { "No tooltip" }
            end
            TooltipContent do
              p { "You won't see this" }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def bookmark_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0z"
      )
    end
  end
end
