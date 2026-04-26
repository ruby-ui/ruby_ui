# frozen_string_literal: true

module Components
  module Shared
    class Menu < Components::Base
      include ComponentsList

      def view_template
        div(class: "pb-4") do
          # Main routes (Docs, Components, Themes, Github, Discord, Twitter)
          div(class: "md:hidden") do
            main_link("Docs", docs_introduction_path)
            main_link("Components", docs_components_path)
            main_link("Themes", theme_path("default"))
            main_link("Github", "https://github.com/ruby-ui/ruby_ui")
            main_link("Discord", ENV["DISCORD_INVITE_LINK"])
            main_link("Discord", ENV["DISCORD_INVITE_LINK"])
          end

          # GETTING STARTED
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold") { "Getting Started" }
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            getting_started_links.each do |getting_started|
              menu_link(getting_started)
            end
          end

          # INSTALLATION
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold") { "Installation" }
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            installation_links.each do |installation|
              menu_link(installation)
            end
          end

          # COMPONENTS
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold flex items-center gap-x-2") do
            plain "Components"
          end
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            components.each do |component|
              menu_link(component)
            end
          end
        end
      end

      def getting_started_links
        [
          {name: "Introduction", path: docs_introduction_path},
          {name: "Installation", path: docs_installation_path},
          {name: "Dark mode", path: docs_dark_mode_path},
          {name: "Theming", path: docs_theming_path},
          {name: "Customizing components", path: docs_customizing_components_path},
          {name: "Changelog", path: docs_changelog_path}
        ]
      end

      def installation_links
        [
          {name: "Rails - JS Bundler", path: docs_installation_rails_bundler_path},
          {name: "Rails - Importmaps", path: docs_installation_rails_importmaps_path}
        ]
      end

      def menu_link(component)
        current_path = component[:path] == request.path
        a(
          href: component[:path],
          class: [
            "group flex w-full items-center rounded-md border border-transparent px-2 py-0.5 transition-colors",
            (current_path ? "text-foreground font-semibold" : "text-foreground hover:bg-zinc-100 dark:hover:bg-zinc-800")
          ]
        ) do
          component[:name]
        end
      end

      def main_link(name, path)
        current_path = path == request.path
        a(
          href: path,
          class: [
            "group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline",
            (current_path ? "text-foreground font-medium" : "text-foreground/80")
          ]
        ) do
          name
        end
      end
    end
  end
end
