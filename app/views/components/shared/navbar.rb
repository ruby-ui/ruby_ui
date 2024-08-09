# frozen_string_literal: true

class Shared::Navbar < ApplicationComponent
  def view_template
    header(class: "supports-backdrop-blur:bg-background/80 sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-2xl backdrop-saturate-200") do
      div(class: "px-2 sm:px-4 sm:container flex h-14 items-center justify-between") do
        div(class: "mr-4 flex items-center") do
          render Shared::MobileMenu.new(class: "md:hidden")
          render Shared::Logo.new

          Link(href: helpers.docs_introduction_path, variant: :ghost, class: "hidden md:inline-block") { "Docs" }
          Link(href: helpers.docs_accordion_path, variant: :ghost, class: "hidden md:inline-block") { "Components" }
          Link(href: helpers.theme_path("default"), variant: :ghost, class: "hidden md:inline-block") { "Themes" }
          Link(href: helpers.lookbook_path("default"), target: "_blank", variant: :ghost, class: "hidden md:inline-block") { "Lookbook" }
        end
        div(class: "flex items-center gap-x-2 md:divide-x") do
          div(class: "flex items-center") do
            twitter_link
            github_link
            dark_mode_toggle
          end
        end
      end
    end
  end

  def dark_mode_toggle
    RBUI.ThemeToggle do |toggle|
      toggle.light_mode do
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

      toggle.dark_mode do
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

  def twitter_link
    Link(href: "https://twitter.com/phlexui", variant: :ghost, icon: true) do
      svg(
        viewbox: "0 0 20 20",
        aria_hidden: "true",
        fill: "currentColor",
        class: "h-4 w-4"
      ) do |s|
        s.path(
          d:
            "M6.29 18.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0 0 20 3.92a8.19 8.19 0 0 1-2.357.646 4.118 4.118 0 0 0 1.804-2.27 8.224 8.224 0 0 1-2.605.996 4.107 4.107 0 0 0-6.993 3.743 11.65 11.65 0 0 1-8.457-4.287 4.106 4.106 0 0 0 1.27 5.477A4.073 4.073 0 0 1 .8 7.713v.052a4.105 4.105 0 0 0 3.292 4.022 4.095 4.095 0 0 1-1.853.07 4.108 4.108 0 0 0 3.834 2.85A8.233 8.233 0 0 1 0 16.407a11.615 11.615 0 0 0 6.29 1.84"
        )
      end
    end
  end

  def github_link
    Link(href: "https://github.com/PhlexUI/phlex_ui", variant: :ghost, icon: true) do
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
