# frozen_string_literal: true

class Docs::Installation::RailsBundlerView < ApplicationView
  def initialize
    @phlex_rails_link = "https://www.phlex.fun/rails/"
    @phlex_ui_pro_private_key = ENV["BUNDLE_PHLEXUI__FURY__SITE"]
  end

  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Rails - JS Bundler", description: "How to install RubyUI within a Rails app that employs JS bundling.")

      Alert(variant: :info) do
        AlertTitle { "RubyUI" }
        AlertDescription { "To take full advantage of RubyUI, the application is expected to be using TailwindCSS and Stimulus" }
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
              bundle add phlex-rails --github phlex-ruby/phlex-rails --branch main
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end

            Alert(variant: :warning) do
              info_icon
              AlertTitle { "Phlex compatibility" }
              AlertDescription { "Note that RubyUI components target Phlex 2, but you can use them with Phlex 1.x as long as you are willing to adapt their code." }
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
              "Include RubyUI styles in your CSS"
            end

            Text do
              plain "Include RubyUI styles in "
              InlineCode(class: "whitespace-nowrap") { "app/assets/stylesheets/application.tailwind.css" }
            end

            Text do
              "Your CSS file will look like this:"
            end

            code = <<~STYLESHEET
              @tailwind base;
              @tailwind components;
              @tailwind utilities;

              @layer base {
                :root {
                  --background: 0 0% 100%;
                  --foreground: 240 10% 3.9%;
                  --card: 0 0% 100%;
                  --card-foreground: 240 10% 3.9%;
                  --popover: 0 0% 100%;
                  --popover-foreground: 240 10% 3.9%;
                  --primary: 240 5.9% 10%;
                  --primary-foreground: 0 0% 98%;
                  --secondary: 240 4.8% 95.9%;
                  --secondary-foreground: 240 5.9% 10%;
                  --muted: 240 4.8% 95.9%;
                  --muted-foreground: 240 3.8% 46.1%;
                  --accent: 240 4.8% 95.9%;
                  --accent-foreground: 240 5.9% 10%;
                  --destructive: 0 84.2% 60.2%;
                  --destructive-foreground: 0 0% 98%;
                  --border: 240 5.9% 90%;
                  --input: 240 5.9% 90%;
                  --ring: 240 5.9% 10%;
                  --radius: 0.5rem;

                  /* ruby_ui especific */
                  --warning: 38 92% 50%;
                  --warning-foreground: 0 0% 100%;
                  --success: 87 100% 37%;
                  --success-foreground: 0 0% 100%;
                }

                .dark {
                  --background: 240 10% 3.9%;
                  --foreground: 0 0% 98%;
                  --card: 240 10% 3.9%;
                  --card-foreground: 0 0% 98%;
                  --popover: 240 10% 3.9%;
                  --popover-foreground: 0 0% 98%;
                  --primary: 0 0% 98%;
                  --primary-foreground: 240 5.9% 10%;
                  --secondary: 240 3.7% 15.9%;
                  --secondary-foreground: 0 0% 98%;
                  --muted: 240 3.7% 15.9%;
                  --muted-foreground: 240 5% 64.9%;
                  --accent: 240 3.7% 15.9%;
                  --accent-foreground: 0 0% 98%;
                  --destructive: 0 62.8% 30.6%;
                  --destructive-foreground: 0 0% 98%;
                  --border: 240 3.7% 15.9%;
                  --input: 240 3.7% 15.9%;
                  --ring: 240 4.9% 83.9%;

                  /* ruby_ui especific */
                  --warning: 38 92% 50%;
                  --warning-foreground: 0 0% 100%;
                  --success: 84 81% 44%;
                  --success-foreground: 0 0% 100%;
                }
              }

              @layer base {
                * {
                  @apply border-border;
                }

                body {
                  @apply bg-background text-foreground;
                  font-feature-settings: "rlig" 1, "calt" 1;

                  /* docs specific */
                  /* https://css-tricks.com/snippets/css/system-font-stack/ */
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
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
              "Install tailwindcss-animate plugin"
            end

            Text do
              plain "Some RubyUI components utilize CSS animations to create smooth transitions."
            end

            code = <<~CODE
              yarn add tailwindcss-animate
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end

        steps.add_step do
          step_container do
            Text(size: "4", weight: "semibold") do
              "Include RubyUI TailwindCSS theme"
            end

            Text do
              plain "Include RubyUI theme config in "
              InlineCode(class: "whitespace-nowrap") { "tailwind.config.js" }
            end

            Text do
              "Your config file will look like this:"
            end

            code = <<~JAVASCRIPT
              module.exports = {
                content: [
                  './app/views/**/*.rb', // Phlex views
                  './app/components/**/*.rb', // Phlex components
                  './app/views/**/*.html.erb',
                  './app/helpers/**/*.rb',
                  './app/assets/stylesheets/**/*.css',
                  './app/javascript/**/*.js'
                ],
                darkMode: ["class"],
                theme: {
                  container: {
                    center: true,
                    padding: "2rem",
                    screens: {
                      "2xl": "1400px",
                    },
                  },
                  extend: {
                    colors: {
                      border: "hsl(var(--border))",
                      input: "hsl(var(--input))",
                      ring: "hsl(var(--ring))",
                      background: "hsl(var(--background))",
                      foreground: "hsl(var(--foreground))",
                      primary: {
                        DEFAULT: "hsl(var(--primary))",
                        foreground: "hsl(var(--primary-foreground))",
                      },
                      secondary: {
                        DEFAULT: "hsl(var(--secondary))",
                        foreground: "hsl(var(--secondary-foreground))",
                      },
                      destructive: {
                        DEFAULT: "hsl(var(--destructive))",
                        foreground: "hsl(var(--destructive-foreground))",
                      },
                      muted: {
                        DEFAULT: "hsl(var(--muted))",
                        foreground: "hsl(var(--muted-foreground))",
                      },
                      accent: {
                        DEFAULT: "hsl(var(--accent))",
                        foreground: "hsl(var(--accent-foreground))",
                      },
                      popover: {
                        DEFAULT: "hsl(var(--popover))",
                        foreground: "hsl(var(--popover-foreground))",
                      },
                      card: {
                        DEFAULT: "hsl(var(--card))",
                        foreground: "hsl(var(--card-foreground))",
                      },
                      /* ruby_ui especific */
                      warning: {
                        DEFAULT: "hsl(var(--warning))",
                        foreground: "hsl(var(--warning-foreground))",
                      },
                      success: {
                        DEFAULT: "hsl(var(--success))",
                        foreground: "hsl(var(--success-foreground))",
                      },
                    },
                    borderRadius: {
                      lg: `var(--radius)`,
                      md: `calc(var(--radius) - 2px)`,
                      sm: "calc(var(--radius) - 4px)",
                    },
                    fontFamily: {
                      sans: ["var(--font-sans)", 'ui-sans-serif', 'system-ui', 'sans-serif', '"Apple Color Emoji"', '"Segoe UI Emoji"', '"Segoe UI Symbol"', '"Noto Color Emoji"'],
                    },
                  },
                },
                plugins: [
                  require("tailwindcss-animate"),
                ],
              }
            JAVASCRIPT

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

  def arrow_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-4 h-4 ml-1.5 -mr-1"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M4.5 12h15m0 0l-6.75-6.75M19.5 12l-6.75 6.75"
      )
    end
  end
end
