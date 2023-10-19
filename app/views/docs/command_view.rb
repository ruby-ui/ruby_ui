# frozen_string_literal: true

class Docs::CommandView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Command" }
        render Typography::P.new { "Fast, composable, unstyled command menu for Phlex." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render CommandDialog.new do
          render CommandDialogTrigger.new do
            render Button.new(variant: "outline", class: 'pr-32') do
              search_icon
              plain "Search"
            end
          end
          render CommandDialogContent.new do
            render Command.new do
              render CommandInput.new(placeholder: "Type a command or search...")
              render CommandEmpty.new { "No results found." }
              render CommandList.new do
                render CommandGroup.new(title: "Suggestions") do
                  render CommandItem.new(value: "calendar", href: helpers.docs_calendar_path) do
                    default_icon
                    plain "Calendar"
                  end
                  render CommandItem.new(value: "chat") do
                    default_icon
                    plain "Chat"
                  end
                  render CommandItem.new(value: "search-emoji") do
                    default_icon
                    plain "Search Emoji"
                  end
                  render CommandItem.new(value: "launch") do
                    default_icon
                    plain "Launch Phlex"
                  end
                end
                render CommandGroup.new(title: "Settings") do
                  render CommandItem.new(value: "profile") do
                    default_icon
                    plain "Profile"
                  end
                  render CommandItem.new(value: "mail") do
                    default_icon
                    plain "Mail"
                  end
                  render CommandItem.new(value: "settings") do
                    default_icon
                    plain "Settings"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def search_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      class: "w-4 h-4 mr-1.5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z",
        clip_rule: "evenodd"
      )
    end
  end

  def default_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M4.5 12h15m0 0l-6.75-6.75M19.5 12l-6.75 6.75"
      )
    end
  end
end
