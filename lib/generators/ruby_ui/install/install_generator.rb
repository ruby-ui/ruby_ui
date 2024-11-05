require "net/http"
require_relative "../base_generator"

# TODO: make ejctectec components work without the gem
module RubyUI
  module Generators
    class InstallGenerator < RubyUI::Generators::BaseGenerator
      namespace "ruby_ui:install"

      if defined?(Rails::Generators::Base)
        source_root File.expand_path("templates", __dir__)

        def confirm_installation
          return if yes?("You need tailwindcss installed. Continue? (y/n)")
          say "Installation cancelled.", :red
          exit
        end

        def add_phlex_rails
          say "Checking for Phlex Rails"
          if gem_installed?("phlex-rails")
            say "Phlex Rails is already installed", :green
          else
            say "Adding Phlex Rails"
            run "bundle add phlex-rails --version=\"~> 2.0.0.beta2\""
          end

          say "Adding tailwind_merge"
          run "bundle add tailwind_merge"

          say "run phlex install"
          run "bin/rails generate phlex:install"
        end

        def install_stuff
          # make default option no
          # extend the yes func to have a default option y/(n) and also allow for enter to accedpt the default

          if ENV["TEST_DATA"] == "true"
            say "Do you want to set up the dev test data?"
            say "Add index controller"
            run "bin/rails generate controller static index --no-helper --no-assets --no-test-framework --no-jbuilder"

            say "Add index view"
            run "bin/rails g phlex:view Static::Index"

            append_to_file "app/controllers/static_controller.rb", after: "  def index" do
              # remove view because phlex is removing view
              "\n    render Static::IndexView"
            end

            template "index_view.rb", "app/views/static/index_view.rb", force: true

            say "Add index route"
            append_to_file "config/routes.rb", after: "Rails.application.routes.draw do" do
              "\n  root to: \"static#index\"\n"
            end
          end

          tailwind_config_path = Rails.root.join("config/tailwind.config.js")
          if !File.exist?(tailwind_config_path)
            say "Tailwind CSS is required for RubyUI", :red
          end

          say "Add ruby_ui initializer"
          template "base_store_initializer.rb", "config/initializers/ruby_ui.rb"

          if using_importmap?
            say "Using importmaps, adding tailwind-animate"
            run "bin/importmap pin tailwindcss-animate"

            # Remove the default pin
            gsub_file "config/importmap.rb", /^pin "tailwindcss-animate".*$\n/, ""

            # Add the vendor-specific pin
            append_to_file "config/importmap.rb" do
              'pin "tailwindcss-animate", to: "tailwindcss-animate.js", preload: true' + "\n"
            end

          else
            say "Not using importmaps, adding tailwind-animate via yarn"
            run "yarn add tailwindcss-animate"
          end

          # check if tailwind.config is in config dir or in root or ask to specify a path
          say "update tailwind.config.js"
          template "tailwind.config.js", "config/tailwind.config.js", force: true, assigns: {using_importmap: using_importmap?}

          say "Add CSS variables"
          template "application.tailwind.css", "app/assets/stylesheets/application.tailwind.css", force: true
        end

        def pin_ruby_ui_js
          stimulus_path = Rails.root.join("app/javascript/application.js")
          package_name = "ruby_ui-js"

          say "Add RubyUI Stimulus controllers"
          # run "mkdir -p app/javascript/controllers/ruby_ui-js"
          template "index.js", "app/components/ruby_ui/index.js"

          if using_importmap?
            gsub_file "app/components/ruby_ui/index.js", /^import { application }.*$/ do
              'import { application } from "controllers/application";'
            end

            append_to_file Rails.root.join("config/initializers/assets.rb") do
              "Rails.application.config.assets.paths << Rails.root.join(\"app/components\")\n"
            end

            say "Pin #{package_name}"
            append_to_file Rails.root.join("config/importmap.rb") do
              "pin_all_from \"app/components/ruby_ui\", under: \"ruby_ui\"\n"
            end

            run "bin/importmap pin #{package_name}"
            append_to_file stimulus_path, "\nimport \"ruby_ui\";\n"

            manifest_path = Rails.root.join("app/assets/config/manifest.js")
            if File.exist?(manifest_path)
              append_to_file manifest_path, "\n//= link ruby_ui/index.js\n"
            end

            fix_import_maps!
          else
            say "Add ruby_ui-js package"
            run "yarn add #{package_name}"

            append_to_file stimulus_path, "\nimport \"../components/ruby_ui\";\n"

            run "yarn build"
          end
        end

        def include_ruby_ui
          message = "Include RubyUI in your global component layout?\n This allows to call RubyUI.Button {\"button\"} / RubyUI::Button.new {\"button\"} with Button  {\"button\"} (y/n)"
          if yes?(message)
            say "Add RubyUI to your global component layout"
            insert_into_file "app/views/application_view.rb", after: "class ApplicationView < ApplicationComponent\n" do
              "  include RubyUI\n"
            end
          end
        end

      else
        def self.source_root
          File.expand_path("templates", __dir__)
        end

        def add_stylesheet_link
          puts "This generator can only be run in a Rails environment."
        end

        def revoke
          puts "This generator can only be run in a Rails environment."
        end
      end

      private

      def fix_import_maps!
        importmap_config_path = Rails.root.join("config/importmap.rb")

        gsub_file importmap_config_path, /^pin "date-fns".*$/ do
          'pin "date-fns", to: "https://ga.jspm.io/npm:date-fns@3.3.1/index.mjs"'
        end
        run "bin/importmap pin @popperjs/core@2.11.8/+esm  --from jsdelivr"

        run "mv vendor/javascript/@popperjs--core--+esm.js vendor/javascript/stupid-popper-lib-2024.js"

        append_to_file importmap_config_path do
          'pin "@popperjs/core", to: "stupid-popper-lib-2024.js"'
        end

        uri = URI "https://ga.jspm.io/npm:chart.js@3.9.1/dist/chart.min.js"
        request = Net::HTTP::Get.new uri

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
          http.request(request)
        }

        File.write(Rails.root.join("vendor/javascript/chart.js--auto.js"), response.body) if response.is_a?(Net::HTTPSuccess)

        append_to_file Rails.root.join("app/views/layouts/application.html.erb"), before: "</body>" do
          "<script>
            window.process = { env: { NODE_ENV: 'production'} }
          </script>"
        end
      end

      def gem_installed?(name)
        Gem::Specification.find_all_by_name(name).any?
      end
    end
  end
end
