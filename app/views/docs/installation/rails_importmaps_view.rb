# frozen_string_literal: true

class Docs::Installation::RailsImportmapsView < ApplicationView
  def initialize
    @phlex_rails_link = "https://www.phlex.fun/rails/"
    @phlex_ui_pro_private_key = ENV['BUNDLE_PHLEXUI__FURY__SITE']
  end

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Rails - Importmaps", description: "How to install PhlexUI within a Rails app that uses Importmaps.", pre_release_only: true)

      render PhlexUI::Alert.new(variant: :warning) do
        alert_icon
        render PhlexUI::Alert::Title.new { "Tailwind plugins not compatible with importmaps" }
        render PhlexUI::Alert::Description.new { "This means that animation using tailwind-animate plugin will not work. I am thinking of a new way to implement this, most likely with a stimulus controller for animations." }
      end


      render PhlexUI::Typography::H2.new(class: '!text-2xl pb-4 border-b') { "Creating a Rails app" }
      render Steps::Builder.new do |steps|
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Generate a new Rails application" }
            render PhlexUI::Typography::P.new do
              plain "In case you don't have a Rails application set up yet, let's start by generating one. The demo uses importmaps (Rails default). "
              render PhlexUI::Typography::InlineLink.new(href: "https://guides.rubyonrails.org/working_with_javascript_in_rails.html#import-maps") { "Read more about Importmaps in Rails here." }
            end
            code = <<~CODE 
                rails new CHANGE_TO_NAME_OF_APP --css=tailwind
              CODE
            div(class: 'w-full') do
              render PhlexUI::Codeblock.new(code, syntax: :javascript)
            end
            render PhlexUI::Typography::P.new { "Once that is created, navigate to the app" }
            code = <<~CODE 
                cd CHANGE_TO_NAME_OF_APP
              CODE
            div(class: 'w-full') do
              render PhlexUI::Codeblock.new(code, syntax: :javascript)
            end
          end
        end
      end

      render PhlexUI::Typography::H2.new(class: '!text-2xl pb-4 border-b') { "Install the gem" }
      render Steps::Builder.new do |steps|
        # STEP 1
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Install Phlex" }
            render PhlexUI::Typography::P.new { "Run the following in the terminal to install phlex for Rails" }
            code = <<~CODE 
                bundle add phlex-rails
              CODE
            div(class: 'w-full') do
              render PhlexUI::Codeblock.new(code, syntax: :javascript)
            end
            render PhlexUI::Typography::P.new { "After the gem is installed, run the generator to create necessary files." }
            code = <<~CODE 
                bin/rails generate phlex:install
              CODE
            div(class: 'w-full') do
              render PhlexUI::Codeblock.new(code, syntax: :javascript)
            end
            render PhlexUI::Typography::P.new do
              plain "Refer to the "
              render Typography::InlineLink.new(href: @phlex_rails_link) { "Phlex installation guide for Rails" }
              plain " for more information."
            end
          end
        end
        # STEP 2
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Install PhlexUI gem" }
            render PhlexUI::Tabs.new(default: free_or_pro) do
              render PhlexUI::Tabs::List.new do
                render PhlexUI::Tabs::Trigger.new(value: "free", class: 'w-24') { "Free" }
                render PhlexUI::Tabs::Trigger.new(value: "pro", class: 'w-24') { "Pro" }
              end
              render PhlexUI::Card.new(class: 'p-4 md:p-6 mt-4 shadow-none') do
                render PhlexUI::Tabs::Content.new(value: "free", class: 'space-y-4 !mt-0') do
                  phlex_ui_installation("free")
                end
                render PhlexUI::Tabs::Content.new(value: "pro", class: 'space-y-4 !mt-0') do
                  if Current.user_subscribed?
                    phlex_ui_installation("pro")
                  else
                    upgrade_to_pro
                  end
                end
              end
            end
          end
        end
      end

      # JS INSTALLATION
      render PhlexUI::Typography::H2.new(class: '!text-2xl pb-4 border-b') { "Install JS" }
      js_installation

      # STYLE INSTALLATION
      render PhlexUI::Typography::H2.new(class: '!text-2xl pb-4 border-b') { "Install Styles" }
      render Steps::Builder.new do |steps|
        # STEP 1
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Install TailwindCSS" }
            render PhlexUI::Typography::P.new do
              plain "In this guide we have already installed TailwindCSS, however if you have not done this make sure to follow the "
              render Typography::InlineLink.new(href: "https://tailwindcss.com/docs/guides/ruby-on-rails") { "TailwindCSS installation guide" }
            end
          end
        end

        # STEP 2
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Update Tailwind Configuration" }
            render PhlexUI::Typography::P.new do
              plain "Add the following to your "
              render PhlexUI::Typography::InlineCode.new(class: 'whitespace-nowrap') { "tailwind.config.js" }
              plain " file"
            end

            code = Current.user_subscribed? ? tailwind_config_pro : tailwind_config
            render PhlexUI::Codeblock.new(code, syntax: :javascript)
          end
        end

        # STEP 3
        steps.add_step do
          step_container do
            render PhlexUI::Typography::Large.new { "Add CSS variables" }
            render PhlexUI::Typography::P.new do
              plain "Add the following to your "
              render PhlexUI::Typography::InlineCode.new { "app/assets/stylesheets/application.tailwind.css" }
              plain " file"
            end
            code = css_variables
            render PhlexUI::Codeblock.new(code, syntax: :css)
          end
        end
      end
    end
  end

  private

  def step_container(&block)
    div(class: "space-y-4", &block)
  end

  def phlex_ui_installation(plan)
    case plan
    when "free"
      render PhlexUI::Typography::P.new { "Run the following in the terminal to install the PhlexUI Component Library" }
      code = <<~CODE 
          bundle add phlex_ui --source 'https://phlexui.fury.site/gem/'
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :javascript)
    when "pro"
      render PhlexUI::Typography::P.new do
        plain "Your license key is "
        render PhlexUI::Typography::InlineCode.new(class: 'whitespace-nowrap') { @phlex_ui_pro_private_key }
      end
      render PhlexUI::Typography::P.new { "Use it to set your license key in development" }
      code = <<~CODE 
          export BUNDLE_PHLEXUI__FURY__SITE=#{@phlex_ui_pro_private_key}
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :javascript)
      render PhlexUI::Typography::P.new { "Check that the key is set" }
      code = <<~CODE
          echo $BUNDLE_PHLEXUI__FURY__SITE
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :javascript)
      render PhlexUI::Typography::P.new { "If you see your key printed in the terminal, you're good to continue" }
      
      render PhlexUI::Typography::P.new { "Now you can install the Pro version of PhlexUI" }
      code = <<~CODE 
          bundle add phlex_ui_pro --source 'https://phlexui.fury.site/gem/'
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :javascript)
    end
  end

  def js_installation
    render Steps::Builder.new do |steps|
      # STEP 1
      steps.add_step do
        step_container do
          render PhlexUI::Typography::Large.new { "Install package" }
          render PhlexUI::Typography::P.new { "Run the following in the terminal to install PhlexUI JS package" }
          code = <<~CODE 
              bin/importmap pin phlex_ui
            CODE
          render PhlexUI::Codeblock.new(code, syntax: :javascript)
        end
      end

      # STEP 2
      steps.add_step do
        render PhlexUI::Typography::Large.new { "Import package" }
        render PhlexUI::Typography::P.new do
          plain "Import the package in your "
          render PhlexUI::Typography::InlineCode.new(class: 'whitespace-nowrap') { "app/javascript/application.js" }
          plain " file"
        end
        code = <<~CODE
            import 'phlex_ui';
          CODE
        render PhlexUI::Codeblock.new(code, syntax: :javascript)
      end
    end
  end

  def upgrade_to_pro
    div(class: "overflow-hidden rounded-lg") do
      render PhlexUI::AspectRatio.new(aspect_ratio: "3/2") do
        img(
          alt: "Placeholder",
          loading: "lazy",
          src:
            helpers.image_path('installation_blur.jpg'),
          class: "opacity-20 blur-xl",
        )
        div(class: "absolute inset-0 p-6 flex flex-col items-center justify-center") do
          render PhlexUI::Card.new(class: 'max-w-md mx-auto') do
            render PhlexUI::Card::Header.new do
              render PhlexUI::Card::Title.new { 'Upgrade to PhlexUI Pro' }
              render PhlexUI::Card::Description.new do 
                "Get access to all components, boost your productivity and take your projects to the next level."
              end
            end
            render PhlexUI::Card::Footer.new(class: 'flex justify-end gap-x-2') do
              render PhlexUI::Link.new(href: helpers.root_path(anchor: :pricing), variant: :primary) do
                plain "Get all access"
                arrow_icon
              end
            end
          end
        end
      end
    end
  end

  def tailwind_config
    <<~CODE
      // For importing tailwind styles from phlex_ui/phlex_ui_pro gem
      const execSync = require('child_process').execSync;

      // Import phlex_ui gem path (To make sure Tailwind loads classes used by phlex_ui gem)
      const outputPhlexUI = execSync('bundle show phlex_ui', { encoding: 'utf-8' });
      const phlex_ui_path = outputPhlexUI.trim() + '/**/*.rb';

      const defaultTheme = require('tailwindcss/defaultTheme')

      module.exports = {
        darkMode: ["class"],
        content: [
          './app/views/**/*.{erb,haml,html,slim,rb}',
          './app/helpers/**/*.rb',
          './app/assets/stylesheets/**/*.css',
          './app/javascript/**/*.js',
          phlex_ui_path
        ],
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
              warning: {
                DEFAULT: "hsl(var(--warning))",
                foreground: "hsl(var(--warning-foreground))",
              },
              success: {
                DEFAULT: "hsl(var(--success))",
                foreground: "hsl(var(--success-foreground))",
              },
              muted: {
                DEFAULT: "hsl(var(--muted))",
                foreground: "hsl(var(--muted-foreground))",
              },
              accent: {
                DEFAULT: "hsl(var(--accent))",
                foreground: "hsl(var(--accent-foreground))",
              },
            },
            borderRadius: {
              lg: `var(--radius)`,
              md: `calc(var(--radius) - 2px)`,
              sm: "calc(var(--radius) - 4px)",
            },
            fontFamily: {
              sans: defaultTheme.fontFamily.sans,
            },
          },
        },
      }
    CODE
  end

  def tailwind_config_pro
    <<~CODE
      // For importing tailwind styles from phlex_ui/phlex_ui_pro gem
      const execSync = require('child_process').execSync;

      // Import phlex_ui gem path (To make sure Tailwind loads classes used by phlex_ui gem)
      const outputPhlexUI = execSync('bundle show phlex_ui', { encoding: 'utf-8' });
      const phlex_ui_path = outputPhlexUI.trim() + '/**/*.rb';

      // Import phlex_ui_pro gem path (To make sure Tailwind loads classes used by phlex_ui_pro gem)
      const outputPhlexUIPro = execSync('bundle show phlex_ui_pro', { encoding: 'utf-8' });
      const phlex_ui_pro_path = outputPhlexUIPro.trim() + '/**/*.rb';

      const defaultTheme = require('tailwindcss/defaultTheme')

      module.exports = {
        darkMode: ["class"],
        content: [
          './app/views/**/*.{erb,haml,html,slim,rb}',
          './app/helpers/**/*.rb',
          './app/assets/stylesheets/**/*.css',
          './app/javascript/**/*.js',
          phlex_ui_path,
          phlex_ui_pro_path
        ],
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
              warning: {
                DEFAULT: "hsl(var(--warning))",
                foreground: "hsl(var(--warning-foreground))",
              },
              success: {
                DEFAULT: "hsl(var(--success))",
                foreground: "hsl(var(--success-foreground))",
              },
              muted: {
                DEFAULT: "hsl(var(--muted))",
                foreground: "hsl(var(--muted-foreground))",
              },
              accent: {
                DEFAULT: "hsl(var(--accent))",
                foreground: "hsl(var(--accent-foreground))",
              },
            },
            borderRadius: {
              lg: `var(--radius)`,
              md: `calc(var(--radius) - 2px)`,
              sm: "calc(var(--radius) - 4px)",
            },
            fontFamily: {
              sans: defaultTheme.fontFamily.sans,
            },
          },
        },
      }
    CODE
  end

  def css_variables
    <<~CODE
      @tailwind base;
      @tailwind components;
      @tailwind utilities;


      @layer base {
        :root {
          --background: 0 0% 100%;
          --foreground: 0 0% 3.9%;
          --primary: 0 0% 9%;
          --primary-foreground: 0 0% 98%;
          --secondary: 0 0% 96.1%;
          --secondary-foreground: 0 0% 9%;
          --muted: 0 0% 96.1%;
          --muted-foreground: 0 0% 45.1%;
          --accent: 0 0% 96.1%;
          --accent-foreground: 0 0% 9%;
          --destructive: 350 89% 60%;
          --destructive-foreground: 0 0% 100%;
          --warning: 38 92% 50%;
          --warning-foreground: 0 0% 100%;
          --success: 87 100% 37%;
          --success-foreground: 0 0% 100%;
          --border: 0 0% 89.8%;
          --input: 0 0% 89.8%;
          --ring: 0 0% 3.9%;
          --radius: 0.5rem;
        }
      
        .dark {
          --background: 0 0% 3.9%;
          --foreground: 0 0% 98%;
          --primary: 0 0% 98%;
          --primary-foreground: 0 0% 9%;
          --secondary: 0 0% 14.9%;
          --secondary-foreground: 0 0% 98%;
          --muted: 0 0% 14.9%;
          --muted-foreground: 0 0% 63.9%;
          --accent: 0 0% 14.9%;
          --accent-foreground: 0 0% 98%;
          --destructive: 350 89% 60%;
          --destructive-foreground: 0 0% 100%;
          --warning: 38 92% 50%;
          --warning-foreground: 0 0% 100%;
          --success: 84 81% 44%;
          --success-foreground: 0 0% 100%;
          --border: 0 0% 14.9%;
          --input: 0 0% 14.9%;
          --ring: 0 0% 83.1%;
        }
      }

      @layer base {
        * {
          @apply border-border;
        }
        body {
          @apply bg-background text-foreground;
          font-feature-settings: "rlig" 1, "calt" 1;
        }
      }
    CODE
  end

  def free_or_pro
    Current.user_subscribed? ? "pro" : "free"
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

  def alert_icon
      svg(
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "w-5 h-5"
      ) do |s|
          s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              d:
              "M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"
          )
      end
  end
end

