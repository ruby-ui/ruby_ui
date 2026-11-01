# frozen_string_literal: true

class Views::Docs::Alert < Views::Base
  def view_template
    component = "Alert"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Alert", description: "Displays a callout for user attention.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "An icon placed first gets its own column next to the title and description.", context: self) do
        <<~RUBY
          Alert do
            info_icon
            AlertTitle { "Heads up!" }
            AlertDescription { "You can add components to your app using the CLI." }
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

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          Alert(variant: :destructive) do
            circle_alert_icon
            AlertTitle { "Something went wrong" }
            AlertDescription { "Your session has expired. Please log in again." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Warning", description: "Warning and success are RubyUI extras, styled like destructive.", context: self) do
        <<~RUBY
          Alert(variant: :warning) do
            triangle_alert_icon
            AlertTitle { "Ship often" }
            AlertDescription { "Shipping is good, your users will thank you for it." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Success", context: self) do
        <<~RUBY
          Alert(variant: :success) do
            circle_check_icon
            AlertTitle { "Installation successful" }
            AlertDescription { "You're all set to start using RubyUI in your application." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Action", description: "AlertAction pins a control to the top-right corner.", context: self) do
        <<~RUBY
          Alert do
            info_icon
            AlertTitle { "Dark mode is now available" }
            AlertDescription { "Enable it under your profile settings." }
            AlertAction do
              Button(variant: :outline, size: :sm) { "Enable" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Static callout", description: "Alert has role=\"alert\": screen readers announce it right away, interrupting the user. Pass role: \"status\" to announce it without interrupting, or role: nil for a message that is part of the page.", context: self) do
        <<~RUBY
          Alert(role: nil) do
            AlertTitle { "Pro tip" }
            AlertDescription { "With RubyUI you'll ship faster." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Title as a heading", description: "AlertTitle is a plain div. To list the alert in the page's headings, put a heading of the right level inside it.", context: self) do
        <<~RUBY
          Alert(role: nil) do
            AlertTitle { h3 { "Billing" } }
            AlertDescription { "Your plan renews on the first day of each month." }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  # lucide icons, as lucide-react renders them (24x24, aria-hidden, no size class):
  # the Alert sizes them to 16px.
  def lucide_icon(&)
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      aria_hidden: "true",
      &
    )
  end

  def info_icon
    lucide_icon do |s|
      s.circle(cx: "12", cy: "12", r: "10")
      s.path(d: "M12 16v-4")
      s.path(d: "M12 8h.01")
    end
  end

  def circle_alert_icon
    lucide_icon do |s|
      s.circle(cx: "12", cy: "12", r: "10")
      s.line(x1: "12", x2: "12", y1: "8", y2: "12")
      s.line(x1: "12", x2: "12.01", y1: "16", y2: "16")
    end
  end

  def triangle_alert_icon
    lucide_icon do |s|
      s.path(d: "m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3")
      s.path(d: "M12 9v4")
      s.path(d: "M12 17h.01")
    end
  end

  def circle_check_icon
    lucide_icon do |s|
      s.circle(cx: "12", cy: "12", r: "10")
      s.path(d: "m16 9-5.5 5.5L8 12")
    end
  end
end
