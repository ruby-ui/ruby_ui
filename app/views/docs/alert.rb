# frozen_string_literal: true

class Views::Docs::Alert < Views::Base
  def view_template
    component = "Alert"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Alert", description: "Displays a callout for user attention.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Alert do
            rocket_icon
            AlertTitle { "Pro tip" }
            AlertDescription { "With RubyUI you'll ship faster." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Without Icon", context: self) do
        <<~RUBY
          Alert do
            AlertTitle { "Pro tip" }
            AlertDescription { "Simply, don't include an icon and your alert will look like this." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Warning", context: self) do
        <<~RUBY
          Alert(variant: :warning) do
            info_icon
            AlertTitle { "Ship often" }
            AlertDescription { "Shipping is good, your users will thank you for it." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          Alert(variant: :destructive) do
            alert_icon
            AlertTitle { "Oopsie daisy!" }
            AlertDescription { "Your design system is non-existent." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Success", context: self) do
        <<~RUBY
          Alert(variant: :success) do
            check_icon
            AlertTitle { "Installation successful" }
            AlertDescription { "You're all set to start using RubyUI in your application." }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def rocket_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M9.315 7.584C12.195 3.883 16.695 1.5 21.75 1.5a.75.75 0 01.75.75c0 5.056-2.383 9.555-6.084 12.436A6.75 6.75 0 019.75 22.5a.75.75 0 01-.75-.75v-4.131A15.838 15.838 0 016.382 15H2.25a.75.75 0 01-.75-.75 6.75 6.75 0 017.815-6.666zM15 6.75a2.25 2.25 0 100 4.5 2.25 2.25 0 000-4.5z",
        clip_rule: "evenodd"
      )
      s.path(
        d:
          "M5.26 17.242a.75.75 0 10-.897-1.203 5.243 5.243 0 00-2.05 5.022.75.75 0 00.625.627 5.243 5.243 0 005.022-2.051.75.75 0 10-1.202-.897 3.744 3.744 0 01-3.008 1.51c0-1.23.592-2.323 1.51-3.008z"
      )
    end
  end

  def alert_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M9.401 3.003c1.155-2 4.043-2 5.197 0l7.355 12.748c1.154 2-.29 4.5-2.599 4.5H4.645c-2.309 0-3.752-2.5-2.598-4.5L9.4 3.003zM12 8.25a.75.75 0 01.75.75v3.75a.75.75 0 01-1.5 0V9a.75.75 0 01.75-.75zm0 8.25a.75.75 0 100-1.5.75.75 0 000 1.5z",
        clip_rule: "evenodd"
      )
    end
  end

  def info_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm8.706-1.442c1.146-.573 2.437.463 2.126 1.706l-.709 2.836.042-.02a.75.75 0 01.67 1.34l-.04.022c-1.147.573-2.438-.463-2.127-1.706l.71-2.836-.042.02a.75.75 0 11-.671-1.34l.041-.022zM12 9a.75.75 0 100-1.5.75.75 0 000 1.5z",
        clip_rule: "evenodd"
      )
    end
  end

  def check_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm13.36-1.814a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.14-.094l3.75-5.25z",
        clip_rule: "evenodd"
      )
    end
  end
end
