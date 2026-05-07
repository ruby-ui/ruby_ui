# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    # Hero Section
    section(class: "space-y-6 pt-6 md:pt-10 lg:pt-16") do
      div(class: "container flex max-w-[64rem] flex-col items-center gap-4 text-center mx-auto") do
        Link(href: docs_changelog_path, variant: :outline, class: "rounded-2xl px-4 py-1.5 text-sm font-medium") do
          span(class: "sm:hidden") { "New components available" }
          span(class: "hidden sm:inline") { "Combobox updates and more" }
          svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "ml-2 h-4 w-4") { |s|
            s.path(d: "M5 12h14")
            s.path(d: "m12 5 7 7-7 7")
          }
        end
        h1(class: "leading-tighter text-3xl font-semibold tracking-tight text-balance text-primary lg:leading-[1.1] lg:font-semibold xl:text-5xl xl:tracking-tighter max-w-4xl") do
          [
            "Build sharp Ruby interfaces.",
            "Reusable UI components for Ruby developers.",
            "Pure Ruby UI, built with Phlex.",
            "Elevate your Rails apps with RubyUI.",
            "The sharpest way to build in Ruby."
          ].sample
        end
        p(class: "max-w-4xl text-base text-balance text-foreground sm:text-lg") do
          "A UI component library, crafted precisely for Ruby devs who want to stay organised and build modern apps, fast."
        end
        div(class: "space-x-4 mt-4") do
          Link(href: docs_introduction_path, variant: :primary, size: :lg) { "Documentation" }
          Link(href: docs_components_path, variant: :outline, size: :lg) { "View Components" }
        end
      end
    end

    # Components Mosaic Section
    section(class: "container py-8 md:py-12 lg:py-24 mx-auto max-w-6xl") do
      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
        # COLUMN 1
        div(class: "space-y-6") do
          # PAYMENT CARD
          Card do
            CardHeader(class: "space-y-1") do
              CardTitle { "Payment Method" }
              CardDescription { "All transactions are secure and encrypted." }
            end
            CardContent(class: "grid gap-4") do
              div(class: "grid gap-2") do
                Label { "Name on Card" }
                Input(placeholder: "John Doe")
              end
              div(class: "grid gap-2") do
                Label { "Card Number" }
                Input(placeholder: "1234 5678 9012 3456")
              end
              div(class: "grid grid-cols-3 gap-4") do
                div(class: "grid gap-2 col-span-2") do
                  Label { "Expires" }
                  div(class: "grid grid-cols-2 gap-2") do
                    Button(variant: :outline, class: "justify-between text-muted-foreground font-normal") do
                      span { "Month" }
                      lucide_icon "chevron-down", class: "h-3 w-3 opacity-50"
                    end
                    Button(variant: :outline, class: "justify-between text-muted-foreground font-normal") do
                      span { "Year" }
                      lucide_icon "chevron-down", class: "h-3 w-3 opacity-50"
                    end
                  end
                end
                div(class: "grid gap-2") do
                  Label { "CVV" }
                  Input(placeholder: "CVV")
                end
              end
              div(class: "flex items-center space-x-2 pt-2") do
                Checkbox(id: "shipping")
                Label(for: "shipping", class: "text-sm font-normal") { "Same as shipping address" }
              end
            end
            CardFooter(class: "flex justify-between gap-2") do
              Button(variant: :outline, class: "flex-1") { "Cancel" }
              Button(class: "flex-1") { "Pay Now" }
            end
          end

          # ALERT Showcase
          Alert do
            lucide_icon "terminal", class: "h-4 w-4"
            AlertTitle { "Heads up!" }
            AlertDescription { "You can add components directly to your app using Phlex." }
          end

          # ACTIVITY FEED
          Card do
            CardHeader(class: "pb-3") do
              CardTitle { "Activity Feed" }
            end
            CardContent(class: "flex flex-wrap gap-2") do
              Badge(variant: :sky) { "In Review" }
              Badge(variant: :success) { "Ready to Ship" }
              Badge(variant: :outline) { "Draft" }
              Badge(variant: :destructive) { "Rejected" }
              Badge(variant: :primary) { "Deployed" }
              Badge(variant: :amber) { "Agent Thinking" }
            end
          end
        end

        # COLUMN 2
        div(class: "space-y-6") do
          # TABS
          Tabs(default_value: "account") do
            TabsList(class: "grid w-full grid-cols-2") do
              TabsTrigger(value: "account") { "Account" }
              TabsTrigger(value: "password") { "Password" }
            end
            TabsContent(value: "account") do
              Card do
                CardHeader do
                  CardTitle { "Account" }
                  CardDescription { "Make changes to your account here." }
                end
                CardContent(class: "space-y-2") do
                  div(class: "space-y-1") do
                    Label { "Username" }
                    Input(placeholder: "@djalma")
                  end
                  div(class: "space-y-1") do
                    Label { "Email" }
                    Input(placeholder: "djalma@nossomos.cc")
                  end
                end
                CardFooter do
                  Button(size: :sm, class: "w-full") { "Save changes" }
                end
              end
            end
          end

          # TEAM MEMBERS
          Card do
            CardHeader do
              CardTitle { "Team Members" }
              CardDescription { "Collaborate with your team." }
            end
            CardContent(class: "space-y-6") do
              team_member("Sofia Davis", "@sdavis", "https://i.pravatar.cc/150?u=sofia")
              team_member("Jackson Lee", "@jlee", "https://i.pravatar.cc/150?u=jackson")
              team_member("Djalma Araújo", "@djalma", "https://i.pravatar.cc/150?u=djalma")
              team_member("George Kettle", "@gkettle", "https://i.pravatar.cc/150?u=george")
            end
            CardFooter do
              Button(variant: :outline, class: "w-full") { "Invite Members" }
            end
          end
        end

        # COLUMN 3
        div(class: "space-y-6") do
          # PROGRESS / QUOTA
          Card do
            CardHeader(class: "pb-4") do
              div(class: "flex items-center justify-between") do
                CardTitle { "Storage Usage" }
                span(class: "text-xs text-muted-foreground") { "12.4GB / 20GB" }
              end
            end
            CardContent do
              Progress(value: 62)
            end
            CardFooter do
              Button(variant: :ghost, size: :sm, class: "w-full text-xs") { "Upgrade Plan" }
            end
          end

          # SETTINGS / SWITCHES
          Card do
            CardHeader do
              CardTitle { "Settings" }
              CardDescription { "Manage your preferences." }
            end
            CardContent(class: "space-y-4") do
              div(class: "flex items-center justify-between rounded-lg border p-4 shadow-sm") do
                div(class: "space-y-0.5") do
                  p(class: "font-medium text-sm") { "Kubernetes" }
                  p(class: "text-xs text-muted-foreground") { "Highly available cluster." }
                end
                Switch(checked: true)
              end
              div(class: "flex items-center justify-between rounded-lg border p-4 shadow-sm") do
                div(class: "space-y-0.5") do
                  p(class: "font-medium text-sm") { "Dark Mode" }
                  p(class: "text-xs text-muted-foreground") { "Use the dark theme." }
                end
                Switch()
              end
            end
          end

          # AI AGENT CHAT
          Card do
            CardHeader(class: "pb-2") do
              div(class: "flex items-center justify-between") do
                CardTitle { "AI Assistant" }
                Badge(variant: :secondary, size: :sm) { "v4.0" }
              end
            end
            CardContent(class: "space-y-4") do
              div(class: "max-w-[80%] rounded-lg bg-muted p-3 text-sm") do
                "How can I help you build with Ruby today?"
              end
              div(class: "flex flex-wrap gap-2") do
                Button(variant: :outline, size: :sm, class: "h-7 text-[10px] gap-1") do
                  lucide_icon "plus", class: "h-3 w-3"
                  span { "Add Context" }
                end
                Button(variant: :outline, size: :sm, class: "h-7 text-[10px] gap-1") do
                  lucide_icon "globe", class: "h-3 w-3"
                  span { "Web Search" }
                end
              end
            end
            CardFooter(class: "flex flex-col gap-3 pt-0") do
              div(class: "flex items-center w-full gap-2") do
                Button(variant: :ghost, size: :icon, class: "h-8 w-8 shrink-0") do
                  lucide_icon "plus-circle", class: "h-4 w-4"
                end
                div(class: "relative flex-1") do
                  Input(placeholder: "Ask anything...", class: "pr-10 h-10")
                  Button(variant: :primary, size: :icon, class: "absolute right-1 top-1 h-8 w-8") do
                    lucide_icon "arrow-up", class: "h-4 w-4"
                  end
                end
              end
              div(class: "flex items-center gap-2 text-[10px] text-muted-foreground") do
                lucide_icon "zap", class: "h-3 w-3"
                span { "GPT-4o" }
                span(class: "mx-1") { "•" }
                lucide_icon "layers", class: "h-3 w-3"
                span { "Professional Plan" }
              end
            end
          end
        end
      end
    end
  end

  private

  def Label(class: nil, **attrs, &block)
    base_classes = "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"

    label(class: [base_classes, binding.local_variable_get(:class)], **attrs, &block)
  end

  def team_member(name, handle, avatar_url)
    div(class: "flex items-center justify-between") do
      div(class: "flex items-center gap-4") do
        Avatar do
          AvatarImage(src: avatar_url, alt: name)
          AvatarFallback { name.split.map(&:first).join }
        end
        div do
          p(class: "text-sm font-medium leading-none") { name }
          p(class: "text-xs text-muted-foreground") { handle }
        end
      end
      Button(variant: :ghost, size: :sm) { "Edit" }
    end
  end

  def activity_item(title, time, status)
    div(class: "flex items-center gap-4") do
      div(class: [
        "h-2 w-2 rounded-full",
        (if status == :success
           "bg-green-500"
         else
           ((status == :warning) ? "bg-amber-500" : "bg-blue-500")
         end)
      ])
      div do
        p(class: "text-sm font-medium") { title }
        p(class: "text-xs text-muted-foreground") { time }
      end
    end
  end
end
