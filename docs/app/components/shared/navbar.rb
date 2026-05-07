# frozen_string_literal: true

module Components
  module Shared
    class Navbar < Components::Base
      include ComponentsList

      def view_template
        header(class: "supports-backdrop-blur:bg-background/80 sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-2xl backdrop-saturate-200") do
          div(class: "px-2 sm:px-4 sm:container flex h-14 items-center justify-between") do
            div(class: "mr-4 flex items-center") do
              render Shared::MobileMenu.new(class: "md:hidden")
              render Shared::Logo.new
              nav(class: "hidden md:flex items-center gap-6 text-sm font-medium") do
                a(href: docs_introduction_path, class: "transition-colors hover:text-foreground/80 text-foreground") { "Docs" }
                a(href: docs_components_path, class: "transition-colors hover:text-foreground/80 text-foreground") { "Components" }
                a(href: theme_path("default"), class: "transition-colors hover:text-foreground/80 text-foreground") { "Themes" }
              end
            end
            div(class: "flex items-center gap-x-2 md:divide-x") do
              div(class: "flex items-center w-full justify-between md:justify-end gap-2") do
                div(class: "w-full flex-1 md:w-auto md:flex-none") do
                  search_button
                end
                div(class: "flex items-center") do
                  github_link
                  dark_mode_toggle
                end
              end
            end
          end
        end
      end

      def dark_mode_toggle
        ThemeToggle do
          SetLightMode do
            Button(variant: :ghost, icon: true) do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-5 h-5"
              ) do |s|
                s.path(
                  d:
                    "M12 2.25a.75.75 0 01.75.75v2.25a.75.75 0 01-1.5 0V3a.75.75 0 01.75-.75zM7.5 12a4.5 4.5 0 119 0 4.5 4.5 0 01-9 0zM18.894 6.166a.75.75 0 00-1.06-1.06l-1.591 1.59a.75.75 0 101.06 1.061l1.591-1.59zM21.75 12a.75.75 0 01-.75.75h-2.25a.75.75 0 010-1.5H21a.75.75 0 01.75.75zM17.834 18.894a.75.75 0 001.06-1.06l-1.59-1.591a.75.75 0 10-1.061 1.06l1.59 1.591zM12 18a.75.75 0 01.75.75V21a.75.75 0 01-1.5 0v-2.25A.75.75 0 0112 18zM7.758 17.303a.75.75 0 00-1.061-1.06l-1.591 1.59a.75.75 0 001.06 1.061l1.591-1.59zM6 12a.75.75 0 01-.75.75H3a.75.75 0 010-1.5h2.25A.75.75 0 016 12zM6.697 7.757a.75.75 0 001.06-1.06l-1.59-1.591a.75.75 0 00-1.061 1.06l1.59 1.591z"
                )
              end
            end
          end
          SetDarkMode do
            Button(variant: :ghost, icon: true) do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-4 h-4"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M9.528 1.718a.75.75 0 01.162.819A8.97 8.97 0 009 6a9 9 0 009 9 8.97 8.97 0 003.463-.69.75.75 0 01.981.98 10.503 10.503 0 01-9.694 6.46c-5.799 0-10.5-4.701-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 01.818.162z",
                  clip_rule: "evenodd"
                )
              end
            end
          end
        end
      end

      def search_button
        CommandDialog do
          CommandDialogTrigger(keybindings: ["keydown.ctrl+k@window", "keydown.meta+k@window"]) do
            Button(variant: :outline, class: "relative h-8 w-full justify-start rounded-[0.5rem] bg-muted/50 text-sm font-normal text-muted-foreground shadow-none sm:pr-12 md:w-40 lg:w-64") do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "mr-2") { |s|
                s.circle(cx: "11", cy: "11", r: "8")
                s.path(d: "m21 21-4.3-4.3")
              }
              span(class: "hidden lg:inline-flex") { "Search documentation..." }
              span(class: "inline-flex lg:hidden") { "Search..." }
              kbd(class: "pointer-events-none absolute right-[0.3rem] top-[0.3rem] hidden h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium opacity-100 sm:flex") do
                span(class: "text-xs") { "⌘" }
                plain "K"
              end
            end
          end
          CommandDialogContent(class: "overflow-hidden p-0 shadow-2xl") do
            Command(class: "flex h-full w-full flex-col overflow-hidden") do
              CommandInput(placeholder: "Search documentation...", class: "border-none focus:ring-0")
              CommandEmpty { "No results found." }
              CommandList(class: "max-h-[min(450px,80vh)] overflow-y-auto p-2") do
                CommandGroup(title: "Components") do
                  components.each do |component|
                    CommandItem(value: component[:name], href: component[:path], class: "px-2 py-1.5") do
                      plain component[:name]
                    end
                  end
                end
                CommandGroup(title: "Links") do
                  CommandItem(value: "Introduction", href: docs_introduction_path, class: "px-2 py-1.5") { "Introduction" }
                  CommandItem(value: "Installation", href: docs_installation_path, class: "px-2 py-1.5") { "Installation" }
                  CommandItem(value: "Theming", href: docs_theming_path, class: "px-2 py-1.5") { "Theming" }
                end
              end
            end
          end
        end
      end

      def github_link
        Link(href: "https://github.com/ruby-ui/ruby_ui", variant: :ghost, icon: true) do
          github_icon
        end
      end

      private

      def arrow_right_icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          class: "w-5 h-5 ml-1 -mr-1"
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M5 10a.75.75 0 01.75-.75h6.638L10.23 7.29a.75.75 0 111.04-1.08l3.5 3.25a.75.75 0 010 1.08l-3.5 3.25a.75.75 0 11-1.04-1.08l2.158-1.96H5.75A.75.75 0 015 10z",
            clip_rule: "evenodd"
          )
        end
      end

      def chevron_down_icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          class: "w-4 h-4 ml-1 -mr-1"
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z",
            clip_rule: "evenodd"
          )
        end
      end

      def github_icon
        svg(
          viewbox: "0 0 16 16",
          class: "w-4 h-4",
          fill: "currentColor",
          aria_hidden: "true"
        ) do |s|
          s.path(
            d:
              "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"
          )
        end
      end

      def account_icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "currentColor",
          class: "w-5 h-5"
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M18.685 19.097A9.723 9.723 0 0021.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 003.065 7.097A9.716 9.716 0 0012 21.75a9.716 9.716 0 006.685-2.653zm-12.54-1.285A7.486 7.486 0 0112 15a7.486 7.486 0 015.855 2.812A8.224 8.224 0 0112 20.25a8.224 8.224 0 01-5.855-2.438zM15.75 9a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z",
            clip_rule: "evenodd"
          )
        end
      end
    end
  end
end
