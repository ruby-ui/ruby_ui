# frozen_string_literal: true

class Docs::Installation::RailsImportmapsView < ApplicationView
  def initialize
    @phlex_rails_link = "https://www.phlex.fun/rails/"
    @phlex_ui_pro_private_key = ENV["BUNDLE_PHLEXUI__FURY__SITE"]
  end

  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Rails - Importmaps", description: "How to install RBUI within a Rails app that uses Importmaps.")

      Alert(variant: :warning) do
        alert_icon
        AlertTitle { "Tailwind plugins not compatible with importmaps" }
        AlertDescription { "This means that animation using tailwind-animate plugin will not work. I am thinking of a new way to implement this, most likely with a stimulus controller for animations." }
      end

      TypographyH2(class: "!text-2xl pb-4 border-b") { "Creating a Rails app" }
      render Steps::Builder.new do |steps|
        steps.add_step do
          step_container do
            TypographyLarge { "Generate a new Rails application" }
            TypographyP do
              plain "In case you don't have a Rails application set up yet, let's start by generating one. The demo uses importmaps (Rails default). "
              TypographyInlineLink(href: "https://guides.rubyonrails.org/working_with_javascript_in_rails.html#import-maps") { "Read more about Importmaps in Rails here." }
            end
            code = <<~CODE
              rails new CHANGE_TO_NAME_OF_APP --css=tailwind
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
            TypographyP { "Once that is created, navigate to the app" }
            code = <<~CODE
              cd CHANGE_TO_NAME_OF_APP
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
          end
        end
      end

      TypographyH2(class: "!text-2xl pb-4 border-b") { "Install the gem" }
      render Steps::Builder.new do |steps|
        # STEP 1
        steps.add_step do
          step_container do
            TypographyLarge { "Install Phlex" }
            TypographyP { "Run the following in the terminal to install phlex for Rails" }
            code = <<~CODE
              bundle add phlex-rails
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
            TypographyP { "After the gem is installed, run the generator to create necessary files." }
            code = <<~CODE
              bin/rails generate phlex:install
            CODE
            div(class: "w-full") do
              Codeblock(code, syntax: :javascript)
            end
            TypographyP do
              plain "Refer to the "
              TypographyInlineLink(href: @phlex_rails_link) { "Phlex installation guide for Rails" }
              plain " for more information."
            end
          end
        end
        # STEP 2
        steps.add_step do
          step_container do
            TypographyLarge { "Install RBUI gem" }
            TypographyP { "Run the following in the terminal to install the RBUI Component Library" }
            code = <<~CODE
              bundle add phlex_ui
            CODE
            Codeblock(code, syntax: :javascript)
          end
        end
        # STEP 3
        steps.add_step do
          step_container do
            TypographyLarge { "Include RBUI module" }
            TypographyP do
              plain "Include RBUI module in your "
              TypographyInlineCode(class: "whitespace-nowrap") { "application_component.rb" }
              plain " file"
            end
            code = <<~CODE
              class ApplicationComponent < Phlex::HTML
                include RBUI
              end
            CODE
            Codeblock(code, syntax: :ruby)
          end
        end
      end

      # JS INSTALLATION
      TypographyH2(class: "!text-2xl pb-4 border-b") { "Install JS" }
      js_installation

      # STYLE INSTALLATION
      TypographyH2(class: "!text-2xl pb-4 border-b") { "Install Styles" }
      render Steps::Builder.new do |steps|
        # STEP 1
        steps.add_step do
          step_container do
            TypographyLarge { "Install TailwindCSS" }
            TypographyP do
              plain "In this guide we have already installed TailwindCSS, however if you have not done this make sure to follow the "
              TypographyInlineLink(href: "https://tailwindcss.com/docs/guides/ruby-on-rails") { "TailwindCSS installation guide" }
            end
          end
        end

        # STEP 2
        steps.add_step do
          step_container do
            render Docs::TailwindConfig.new
          end
        end

        # STEP 3
        steps.add_step do
          step_container do
            render Docs::TailwindCss.new
          end
        end
      end
    end
  end

  private

  def step_container(&)
    div(class: "space-y-4", &)
  end

  def js_installation
    render Steps::Builder.new do |steps|
      # STEP 1
      steps.add_step do
        step_container do
          TypographyLarge { "Install package" }
          TypographyP { "Run the following in the terminal to install RBUI JS package" }
          code = <<~CODE
            bin/importmap pin rbui-js
          CODE
          Codeblock(code, syntax: :javascript)
        end
      end

      # STEP 2
      steps.add_step do
        TypographyLarge { "Import package" }
        TypographyP do
          plain "Import the package in your "
          TypographyInlineCode(class: "whitespace-nowrap") { "app/javascript/application.js" }
          plain " file"
        end
        code = <<~CODE
          import 'rbui-js';
        CODE
        Codeblock(code, syntax: :javascript)
      end
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
