# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def view_template
    render HomeView::Banner.new do |banner|
      banner.cta do
        render PhlexUI::Link.new(variant: :outline, href: helpers.docs_accordion_path, class: "text-center justify-center") { "Browse Components" }
        render PhlexUI::Link.new(variant: :primary, href: helpers.docs_introduction_path, class: "text-center justify-center") do
          plain "Get Started"
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
      end
    end
    div(class: "overflow-hidden") do
      div(class: "relative z-10 container mx-auto max-w-5xl pt-16 lg:pt-16 py-24 lg:py-32 px-4") do
        div(class: "grid grid-cols-6 gap-4") do
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3 md:col-span-4", title: "Built for Speed", subtitle: "Dive into a world where your Rails UI development happens at light speed. Phlex is not just fast - it's blazing fast.", color: :secondary) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M12.963 2.286a.75.75 0 00-1.071-.136 9.742 9.742 0 00-3.539 6.177A7.547 7.547 0 016.648 6.61a.75.75 0 00-1.152-.082A9 9 0 1015.68 4.534a7.46 7.46 0 01-2.717-2.248zM15.75 14.25a3.75 3.75 0 11-7.313-1.172c.628.465 1.35.81 2.133 1a5.99 5.99 0 011.925-3.545 3.75 3.75 0 013.255 3.717z",
                  clip_rule: "evenodd"
                )
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3 md:col-span-2", color: :sky) do |card|
            card.content do
              div(class: "flex flex-col items-center justify-center text-center space-y-4 h-full") do
                p(class: "text-6xl font-semibold") { "12x" }
                p { "Faster than traditional Rails ERB templates" }
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6", color: :card, title: "Speed Tests", subtitle: "Huge thanks to @KonnorRogers for running these tests") do |card|
            card.content do
              render_speed_tests
            end
          end
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3", title: "UI that... Wow!", subtitle: "Design stunning, streamlined, and customizable UIs that not only look great but sell your app without you lifting a finger.", color: :violet) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M9 4.5a.75.75 0 01.721.544l.813 2.846a3.75 3.75 0 002.576 2.576l2.846.813a.75.75 0 010 1.442l-2.846.813a3.75 3.75 0 00-2.576 2.576l-.813 2.846a.75.75 0 01-1.442 0l-.813-2.846a3.75 3.75 0 00-2.576-2.576l-2.846-.813a.75.75 0 010-1.442l2.846-.813A3.75 3.75 0 007.466 7.89l.813-2.846A.75.75 0 019 4.5zM18 1.5a.75.75 0 01.728.568l.258 1.036c.236.94.97 1.674 1.91 1.91l1.036.258a.75.75 0 010 1.456l-1.036.258c-.94.236-1.674.97-1.91 1.91l-.258 1.036a.75.75 0 01-1.456 0l-.258-1.036a2.625 2.625 0 00-1.91-1.91l-1.036-.258a.75.75 0 010-1.456l1.036-.258a2.625 2.625 0 001.91-1.91l.258-1.036A.75.75 0 0118 1.5zM16.5 15a.75.75 0 01.712.513l.394 1.183c.15.447.5.799.948.948l1.183.395a.75.75 0 010 1.422l-1.183.395c-.447.15-.799.5-.948.948l-.395 1.183a.75.75 0 01-1.422 0l-.395-1.183a1.5 1.5 0 00-.948-.948l-1.183-.395a.75.75 0 010-1.422l1.183-.395c.447-.15.799-.5.948-.948l.395-1.183A.75.75 0 0116.5 15z",
                  clip_rule: "evenodd"
                )
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3", title: "Stay Organized", subtitle: "Say goodbye to clutter. With Phlex, your UI components are not only organized, but also easy to manage and track.", color: :secondary) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  d:
                    "M21 6.375c0 2.692-4.03 4.875-9 4.875S3 9.067 3 6.375 7.03 1.5 12 1.5s9 2.183 9 4.875z"
                )
                s.path(
                  d:
                    "M12 12.75c2.685 0 5.19-.586 7.078-1.609a8.283 8.283 0 001.897-1.384c.016.121.025.244.025.368C21 12.817 16.97 15 12 15s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.285 8.285 0 001.897 1.384C6.809 12.164 9.315 12.75 12 12.75z"
                )
                s.path(
                  d:
                    "M12 16.5c2.685 0 5.19-.586 7.078-1.609a8.282 8.282 0 001.897-1.384c.016.121.025.244.025.368 0 2.692-4.03 4.875-9 4.875s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.284 8.284 0 001.897 1.384C6.809 15.914 9.315 16.5 12 16.5z"
                )
                s.path(
                  d:
                    "M12 20.25c2.685 0 5.19-.586 7.078-1.609a8.282 8.282 0 001.897-1.384c.016.121.025.244.025.368 0 2.692-4.03 4.875-9 4.875s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.284 8.284 0 001.897 1.384C6.809 19.664 9.315 20.25 12 20.25z"
                )
              end
            end
          end
          div(class: "relative col-span-6") do
            render HomeView::Shapes.new(color: :violet, class: "hidden md:block absolute top-0 left-0 rotate-90 -translate-x-1/2 translate-y-full", size: :lg)
            div(class: "mx-auto max-w-lg py-28") do
              steps = [
                {
                  title: "Find the perfect component",
                  description: "Each component is embedded live on the page so you can find exactly the design you want."
                },
                {
                  title: "Copy the snippet",
                  description: "Click the \"Code\" tab to see the code for a component and grab the part that you need, or click the clipboard button to quickly copy the entire snippet in one step."
                },
                {
                  title: "Make it yours",
                  description: "Every component is built entirely out of Tailwind utility classes, so you can easily dive in and adjust anything you want to better fit your use case."
                }
              ]
              render HomeView::Steps.new(steps: steps)
            end
          end
          render HomeView::Card.new(class: "col-span-6 md:col-span-4", title: "Customer-Centric UX", subtitle: "Create an app experience your users will rave about. PhlexUI ensures that your user's journey is nothing less than memorable.", color: :pink) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  d:
                    "M4.5 6.375a4.125 4.125 0 118.25 0 4.125 4.125 0 01-8.25 0zM14.25 8.625a3.375 3.375 0 116.75 0 3.375 3.375 0 01-6.75 0zM1.5 19.125a7.125 7.125 0 0114.25 0v.003l-.001.119a.75.75 0 01-.363.63 13.067 13.067 0 01-6.761 1.873c-2.472 0-4.786-.684-6.76-1.873a.75.75 0 01-.364-.63l-.001-.122zM17.25 19.128l-.001.144a2.25 2.25 0 01-.233.96 10.088 10.088 0 005.06-1.01.75.75 0 00.42-.643 4.875 4.875 0 00-6.957-4.611 8.586 8.586 0 011.71 5.157v.003z"
                )
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6 md:col-span-2", title: "Completely Customisable", subtitle: "Have full control over the design of all components.", color: :amber) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M20.599 1.5c-.376 0-.743.111-1.055.32l-5.08 3.385a18.747 18.747 0 00-3.471 2.987 10.04 10.04 0 014.815 4.815 18.748 18.748 0 002.987-3.472l3.386-5.079A1.902 1.902 0 0020.599 1.5zm-8.3 14.025a18.76 18.76 0 001.896-1.207 8.026 8.026 0 00-4.513-4.513A18.75 18.75 0 008.475 11.7l-.278.5a5.26 5.26 0 013.601 3.602l.502-.278zM6.75 13.5A3.75 3.75 0 003 17.25a1.5 1.5 0 01-1.601 1.497.75.75 0 00-.7 1.123 5.25 5.25 0 009.8-2.62 3.75 3.75 0 00-3.75-3.75z",
                  clip_rule: "evenodd"
                )
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3", title: "Minimal Dependencies", subtitle: "Keep your app lean and mean. With PhlexUI, we use custom built Stimulus.js controllers wherever possible - less package dependencies to worry about.", color: :secondary) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  d:
                    "M7.493 18.75c-.425 0-.82-.236-.975-.632A7.48 7.48 0 016 15.375c0-1.75.599-3.358 1.602-4.634.151-.192.373-.309.6-.397.473-.183.89-.514 1.212-.924a9.042 9.042 0 012.861-2.4c.723-.384 1.35-.956 1.653-1.715a4.498 4.498 0 00.322-1.672V3a.75.75 0 01.75-.75 2.25 2.25 0 012.25 2.25c0 1.152-.26 2.243-.723 3.218-.266.558.107 1.282.725 1.282h3.126c1.026 0 1.945.694 2.054 1.715.045.422.068.85.068 1.285a11.95 11.95 0 01-2.649 7.521c-.388.482-.987.729-1.605.729H14.23c-.483 0-.964-.078-1.423-.23l-3.114-1.04a4.501 4.501 0 00-1.423-.23h-.777zM2.331 10.977a11.969 11.969 0 00-.831 4.398 12 12 0 00.52 3.507c.26.85 1.084 1.368 1.973 1.368H4.9c.445 0 .72-.498.523-.898a8.963 8.963 0 01-.924-3.977c0-1.708.476-3.305 1.302-4.666.245-.403-.028-.959-.5-.959H4.25c-.832 0-1.612.453-1.918 1.227z"
                )
              end
            end
          end
          render HomeView::Card.new(class: "col-span-6 sm:col-span-3", title: "Reuse with Ease", subtitle: "Avoid the hassle of constantly reconstructing components. With Phlex, once built, use them seamlessly as needed.", color: :lime) do |card|
            card.icon do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-6 h-6"
              ) do |s|
                s.path(
                  fill_rule: "evenodd",
                  d:
                    "M4.755 10.059a7.5 7.5 0 0112.548-3.364l1.903 1.903h-3.183a.75.75 0 100 1.5h4.992a.75.75 0 00.75-.75V4.356a.75.75 0 00-1.5 0v3.18l-1.9-1.9A9 9 0 003.306 9.67a.75.75 0 101.45.388zm15.408 3.352a.75.75 0 00-.919.53 7.5 7.5 0 01-12.548 3.364l-1.902-1.903h3.183a.75.75 0 000-1.5H2.984a.75.75 0 00-.75.75v4.992a.75.75 0 001.5 0v-3.18l1.9 1.9a9 9 0 0015.059-4.035.75.75 0 00-.53-.918z",
                  clip_rule: "evenodd"
                )
              end
            end
          end
        end
      end
      div(class: "relative z-0 h-72 rotate-180 -mt-56 -mr-px") do
        render Shared::GridPattern.new
      end
      div(class: "relative h-72") do
        render Shared::GridPattern.new
      end
    end
  end

  def speed_tests
    [
      {
        framework: "Phlex",
        time: 1
      },
      {
        framework: "ViewComponent",
        time: 5.57
      },
      {
        framework: "ERB Templates",
        time: 12.08
      }
    ].sort_by { |test| test[:time] }
  end

  def render_speed_tests
    div(class: "space-y-4 overflow-hidden") do
      speed_tests.each do |test|
        div(class: "sm:flex items-center space-y-2 sm:space-x-2") do
          h3(class: "font-semibold leading-none tracking-tight w-40") { test[:framework] }
          div(class: "p-1 rounded-md flex items-center gap-x-2 border flex-grow") do
            # bar with sky gradient
            div(class: "flex-grow") do
              div(class: "bg-gradient-to-r from-sky-400 to-sky-200 rounded h-8", style: "width: #{test[:time] * 100 / speed_tests.last[:time]}%")
            end
            # text with timex
            div(class: "flex-shrink-0 w-20 pr-2") do
              p(class: "text-sm text-right") { "#{test[:time]}x" } if test[:time] > 1
            end
          end
        end
      end
    end
  end
end
