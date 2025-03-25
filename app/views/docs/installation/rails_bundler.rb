# frozen_string_literal: true

class Views::Docs::Installation::RailsBundler < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Rails - JS Bundler", description: "How to install RubyUI within a Rails app that employs JS bundling.")

      Alert(variant: :info) do
        AlertTitle { "RubyUI" }
        AlertDescription { "To take full advantage of RubyUI, the application is expected to be using TailwindCSS 4 and Stimulus" }
      end

      Heading(level: 2, class: "!text-2xl pb-4 border-b") { "Using RubyUI CLI" }
      Text do
        "We provide a Ruby gem with useful generators to help you to setup RubyUI components in your apps."
      end

      render Steps::Builder.new do |steps|
        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              plain "Add RubyUI gem to your Gemfile"
            end

            code = <<~CODE
              bundle add ruby_ui --group development --require false
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end
        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Run the install command"
            end

            code = <<~CODE
              rails g ruby_ui:install
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end
      end

      Heading(level: 2, class: "!text-2xl pb-4 border-b") { "Manual" }
      Text do
        "You can install the dependencies manually if you prefer"
      end
      render Steps::Builder.new do |steps|
        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Add Phlex Rails to your app"
            end

            code = <<~CODE
              bundle add phlex-rails
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end

            Alert(variant: :warning) do
              info_icon
              AlertTitle { "Phlex compatibility" }
              AlertDescription { "Note that RubyUI components target Phlex 2.x most recent version" }
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Install Phlex Rails"
            end

            code = <<~CODE
              bin/rails g phlex:install
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Install tailwind_merge"
            end

            Text do
              "RubyUI components use tailwind_merge to avoid conflicts between TailwindCSS classes"
            end

            code = <<~CODE
              bundle add tailwind_merge
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Create RubyUI initializer"
            end

            Text do
              plain "Add this code to "
              InlineCode(class: "whitespace-nowrap") { "config/initializers/ruby_ui.rb" }
            end

            code = <<~RUBY
              module RubyUI
                extend Phlex::Kit
              end

              # Allow using RubyUI instead RubyUi
              Rails.autoloaders.main.inflector.inflect(
                "ruby_ui" => "RubyUI"
              )

              # Allow using RubyUI::ComponentName instead Components::RubyUI::ComponentName
              Rails.autoloaders.main.push_dir(
                "\#{Rails.root}/app/components/ruby_ui", namespace: RubyUI
              )

              # Allow using RubyUI::ComponentName instead RubyUI::ComponentName::ComponentName
              Rails.autoloaders.main.collapse(Rails.root.join("app/components/ruby_ui/*"))
            RUBY
            div(class: "w-full") do
              Codeblock(code, syntax: :ruby)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Include RubyUI kit in your base component"
            end

            Text do
              plain "Include "
              InlineCode(class: "whitespace-nowrap") { "RubyUI" }
              plain " module in "
              InlineCode(class: "whitespace-nowrap") { "app/components/base.rb" }
            end

            code = <<~RUBY
              module Components
                class Base < Phlex::HTML
                  include Components
                  include RubyUI

                  ...
            RUBY
            div(class: "w-full") do
              Codeblock(code, syntax: :ruby)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Create the RubyUI base component"
            end

            Text do
              plain "Every RubyUI component inherit from RubyUI::Base "
            end

            Text do
              plain "Copy and paste the code snippet below into the "
              InlineCode(class: "whitespace-nowrap") { "app/components/ruby_ui/base.rb" }
              plain " file."
            end

            code = <<~RUBY
              require "tailwind_merge"

              module RubyUI
                class Base < Phlex::HTML
                  TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

                  attr_reader :attrs

                  def initialize(**user_attrs)
                    @attrs = mix(default_attrs, user_attrs)
                    @attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class]) if @attrs[:class]
                  end

                  private

                  def default_attrs
                    {}
                  end
                end
              end
            RUBY
            div(class: "w-full") do
              Codeblock(code, syntax: :ruby)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Include RubyUI configuration & styles in your CSS"
            end

            Text do
              plain "Include RubyUI styles in "
              InlineCode(class: "whitespace-nowrap") { "app/assets/stylesheets/application.tailwind.css" }
            end

            Text do
              "Your CSS file will look like this:"
            end

            code = <<~STYLESHEET
              @import "tailwindcss";

              @plugin "@tailwindcss/forms";
              @plugin "@tailwindcss/typography";

              @import "tw-animate-css";

              @custom-variant dark (&:is(.dark *));

              :root {
                --background: oklch(1 0 0);
                --foreground: oklch(0.145 0 0);
                --card: oklch(1 0 0);
                --card-foreground: oklch(0.145 0 0);
                --popover: oklch(1 0 0);
                --popover-foreground: oklch(0.145 0 0);
                --primary: oklch(0.205 0 0);
                --primary-foreground: oklch(0.985 0 0);
                --secondary: oklch(0.97 0 0);
                --secondary-foreground: oklch(0.205 0 0);
                --muted: oklch(0.97 0 0);
                --muted-foreground: oklch(0.556 0 0);
                --accent: oklch(0.97 0 0);
                --accent-foreground: oklch(0.205 0 0);
                --destructive: oklch(0.577 0.245 27.325);
                --destructive-foreground: oklch(0.577 0.245 27.325);
                --border: oklch(0.922 0 0);
                --input: oklch(0.922 0 0);
                --ring: oklch(0.708 0 0);
                --chart-1: oklch(0.646 0.222 41.116);
                --chart-2: oklch(0.6 0.118 184.704);
                --chart-3: oklch(0.398 0.07 227.392);
                --chart-4: oklch(0.828 0.189 84.429);
                --chart-5: oklch(0.769 0.188 70.08);
                --radius: 0.625rem;
                --sidebar: oklch(0.985 0 0);
                --sidebar-foreground: oklch(0.145 0 0);
                --sidebar-primary: oklch(0.205 0 0);
                --sidebar-primary-foreground: oklch(0.985 0 0);
                --sidebar-accent: oklch(0.97 0 0);
                --sidebar-accent-foreground: oklch(0.205 0 0);
                --sidebar-border: oklch(0.922 0 0);
                --sidebar-ring: oklch(0.708 0 0);

                /* ruby_ui specific */
                --warning: hsl(38 92% 50%);
                --warning-foreground: hsl(0 0% 100%);
                --success: hsl(87 100% 37%);
                --success-foreground: hsl(0 0% 100%);

                /* Container settings */
                --container-center: true;
                --container-padding: hsl(2rem);
                --container-max-width-2xl: hsl(1400px);
              }

              .dark {
                --background: oklch(0.145 0 0);
                --foreground: oklch(0.985 0 0);
                --card: oklch(0.145 0 0);
                --card-foreground: oklch(0.985 0 0);
                --popover: oklch(0.145 0 0);
                --popover-foreground: oklch(0.985 0 0);
                --primary: oklch(0.985 0 0);
                --primary-foreground: oklch(0.205 0 0);
                --secondary: oklch(0.269 0 0);
                --secondary-foreground: oklch(0.985 0 0);
                --muted: oklch(0.269 0 0);
                --muted-foreground: oklch(0.708 0 0);
                --accent: oklch(0.269 0 0);
                --accent-foreground: oklch(0.985 0 0);
                --destructive: oklch(0.396 0.141 25.723);
                --destructive-foreground: oklch(0.637 0.237 25.331);
                --border: oklch(0.269 0 0);
                --input: oklch(0.269 0 0);
                --ring: oklch(0.439 0 0);
                --chart-1: oklch(0.488 0.243 264.376);
                --chart-2: oklch(0.696 0.17 162.48);
                --chart-3: oklch(0.769 0.188 70.08);
                --chart-4: oklch(0.627 0.265 303.9);
                --chart-5: oklch(0.645 0.246 16.439);
                --sidebar: oklch(0.205 0 0);
                --sidebar-foreground: oklch(0.985 0 0);
                --sidebar-primary: oklch(0.488 0.243 264.376);
                --sidebar-primary-foreground: oklch(0.985 0 0);
                --sidebar-accent: oklch(0.269 0 0);
                --sidebar-accent-foreground: oklch(0.985 0 0);
                --sidebar-border: oklch(0.269 0 0);
                --sidebar-ring: oklch(0.439 0 0);

                /* ruby_ui specific */
                --warning: hsl(38 92% 50%);
                --warning-foreground: hsl(0 0% 100%);
                --success: hsl(84 81% 44%);
                --success-foreground: hsl(0 0% 100%);
              }

              @theme inline {
                --color-background: var(--background);
                --color-foreground: var(--foreground);
                --color-card: var(--card);
                --color-card-foreground: var(--card-foreground);
                --color-popover: var(--popover);
                --color-popover-foreground: var(--popover-foreground);
                --color-primary: var(--primary);
                --color-primary-foreground: var(--primary-foreground);
                --color-secondary: var(--secondary);
                --color-secondary-foreground: var(--secondary-foreground);
                --color-muted: var(--muted);
                --color-muted-foreground: var(--muted-foreground);
                --color-accent: var(--accent);
                --color-accent-foreground: var(--accent-foreground);
                --color-destructive: var(--destructive);
                --color-destructive-foreground: var(--destructive-foreground);
                --color-border: var(--border);
                --color-input: var(--input);
                --color-ring: var(--ring);
                --color-chart-1: var(--chart-1);
                --color-chart-2: var(--chart-2);
                --color-chart-3: var(--chart-3);
                --color-chart-4: var(--chart-4);
                --color-chart-5: var(--chart-5);
                --radius-sm: calc(var(--radius) - 4px);
                --radius-md: calc(var(--radius) - 2px);
                --radius-lg: var(--radius);
                --radius-xl: calc(var(--radius) + 4px);
                --color-sidebar: var(--sidebar);
                --color-sidebar-foreground: var(--sidebar-foreground);
                --color-sidebar-primary: var(--sidebar-primary);
                --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
                --color-sidebar-accent: var(--sidebar-accent);
                --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
                --color-sidebar-border: var(--sidebar-border);
                --color-sidebar-ring: var(--sidebar-ring);

                /* ruby_ui specific */
                --color-warning: var(--warning);
                --color-warning-foreground: var(--warning-foreground);
                --color-success: var(--success);
                --color-success-foreground: var(--success-foreground);
              }

              @layer base {
                * {
                  @apply border-border outline-ring/50;
                }
                body {
                  @apply bg-background text-foreground;
                }
              }

            STYLESHEET

            div(class: "w-full") do
              Codeblock(code, syntax: :css)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Install tw-animate-css plugin"
            end

            Text do
              plain "Some RubyUI components utilize CSS animations to create smooth transitions."
            end

            code = <<~CODE
              yarn add tw-animate-css
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end
      end
    end
  end

  private

  def step_container(&)
    div(class: "space-y-4", &)
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
end
