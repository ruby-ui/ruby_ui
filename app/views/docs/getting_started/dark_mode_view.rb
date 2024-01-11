# frozen_string_literal: true

class Docs::GettingStarted::DarkModeView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dark mode", description: "How to use dark mode in your application", pre_release_only: true)

      div(class: "space-y-4") do
        render heading2 { "How it works" }
        render PhlexUI::Typography::P.new { "PhlexUI seamlessly integrates dark mode, a crucial feature for modern applications, enhancing user experience and catering to diverse user preferences." }
        render PhlexUI::Typography::P.new do
          plain "PhlexUI is setup to use the "
          render Typography::InlineLink.new(href: "https://tailwindcss.com/docs/dark-mode#toggling-dark-mode-manually") { "TailwindCSS 'class' strategy" }
          plain ". This means that you can toggle dark mode by adding or removing the "
          render PhlexUI::Typography::InlineCode.new { "dark" }
          plain " class from the "
          render PhlexUI::Typography::InlineCode.new { "<body>" }
          plain " element."
        end
        render PhlexUI::Typography::P.new { "To enable dark mode, follow the installation below." }
      end

      div(class: "space-y-4") do
        render heading2 { "Installation" }
        render PhlexUI::Typography::P.new do
          plain "To implement Dark mode, add the "
          render PhlexUI::Typography::InlineCode.new { "PhlexUI::ThemeToggle" }
          plain " component (below) to your application layout file. This ensures it's available on all pages."
        end
        render PhlexUI::Typography::P.new do
          plain "This component is a button that toggles the "
          render PhlexUI::Typography::InlineCode.new { "dark" }
          plain " class on the "
          render PhlexUI::Typography::InlineCode.new { "<body>" }
          plain " element, using the "
          render PhlexUI::Typography::InlineCode.new { "ToggleThemeController" }
          plain " Stimulus controller."
        end
        render PhlexUI::Alert.new do
          render PhlexUI::Alert::Title.new { "Pro tip" }
          render PhlexUI::Alert::Description.new do
            plain "You can hide the theme toggle on specific pages using classes, like so: "
            render PhlexUI::Typography::InlineCode.new { "render PhlexUI::ThemeToggle.new(class: 'hidden')" }
            plain "."
          end
        end

        div(class: 'pt-4') do
          render Docs::VisualCodeExample.new(title: "Toggle component", context: self) do
            <<~RUBY
              render PhlexUI::ThemeToggle.new do |toggle|
                toggle.light_mode do
                  render PhlexUI::Button.new(variant: :outline, icon: true) do
                    svg(
                      xmlns: "http://www.w3.org/2000/svg",
                      viewbox: "0 0 24 24",
                      fill: "currentColor",
                      class: "w-4 h-4"
                    ) do |s|
                      s.path(
                        d:
                          "M12 2.25a.75.75 0 01.75.75v2.25a.75.75 0 01-1.5 0V3a.75.75 0 01.75-.75zM7.5 12a4.5 4.5 0 119 0 4.5 4.5 0 01-9 0zM18.894 6.166a.75.75 0 00-1.06-1.06l-1.591 1.59a.75.75 0 101.06 1.061l1.591-1.59zM21.75 12a.75.75 0 01-.75.75h-2.25a.75.75 0 010-1.5H21a.75.75 0 01.75.75zM17.834 18.894a.75.75 0 001.06-1.06l-1.59-1.591a.75.75 0 10-1.061 1.06l1.59 1.591zM12 18a.75.75 0 01.75.75V21a.75.75 0 01-1.5 0v-2.25A.75.75 0 0112 18zM7.758 17.303a.75.75 0 00-1.061-1.06l-1.591 1.59a.75.75 0 001.06 1.061l1.591-1.59zM6 12a.75.75 0 01-.75.75H3a.75.75 0 010-1.5h2.25A.75.75 0 016 12zM6.697 7.757a.75.75 0 001.06-1.06l-1.59-1.591a.75.75 0 00-1.061 1.06l1.59 1.591z"
                      )
                    end
                  end
                end

                toggle.dark_mode do
                  render PhlexUI::Button.new(variant: :outline, icon: true) do
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
            RUBY
          end
        end
      end
    end
  end

  def heading2(&block)
    PhlexUI::Typography::H2.new(class: '!text-2xl pb-4 border-b', &block)
  end

  def space_y_4(&block)
    div(class: "space-y-4", &block)
  end

  def space_y_2(&block)
    div(class: "space-y-2", &block)
  end
end
