require "rails/generators"
require_relative "../javascript_utils"

module RubyUI
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include RubyUI::Generators::JavascriptUtils

      namespace "ruby_ui:install"

      source_root File.expand_path("templates", __dir__)

      def install_phlex_rails
        say "Checking for phlex-rails"

        if gem_installed?("phlex-rails")
          if Gem::Specification.find_by_name("phlex-rails").version < "2.0.0.beta2"
            say "You need to upgrade to phlex-rails 2 to use RubyUI", :red
            exit
          else
            say "phlex-rails is already installed", :green
          end
        else
          say "Adding phlex-rails to Gemfile"
          run %(bundle add phlex-rails --github="phlex-ruby/phlex-rails")

          say "Running phlex-rails structure"
          run "bin/rails generate phlex:install"
        end
      end

      def install_tailwind_merge
        say "Checking for tailwind_merge"

        if gem_installed?("tailwind_merge")
          say "tailwind_merge is already installed", :green
        else
          say "Adding phlex-rails to Gemfile"
          run %(bundle add tailwind_merge)
        end
      end

      def install_ruby_ui_initializer
        say "Creating RubyUI initializer"
        template "ruby_ui.rb.erb", Rails.root.join("config/initializers/ruby_ui.rb")
      end

      def add_ruby_ui_module_to_components_base
        say "Adding RubyUI Kit to Components::Base"
        insert_into_file Rails.root.join("app/components/base.rb"), after: "include Components" do
          "\n  include RubyUI"
        end
      end

      def add_tailwind_config
        say "Adding RubyUI config to tailwind config"

        if using_tailwindcss_rails_gem?
          template "application.css.erb", Rails.root.join("app/assets/tailwind/application.css")
        else
          template "application.tailwind.css.erb", Rails.root.join("app/assets/stylesheets/application.tailwind.css")
        end
      end

      def install_tw_animate_css
        say "Installing tw-animate-css plugin"

        install_js_package("tw-animate-css")
      end

      def install_tailwindcss_forms
        say "Installing @tailwindcss/forms plugin"

        install_js_package("@tailwindcss/forms")
      end

      def install_tailwindcss_typography
        say "Installing @tailwindcss/typography plugin"

        install_js_package("@tailwindcss/typography")
      end

      def add_ruby_ui_base
        say "Adding RubyUI::Base component"
        template "../../../../ruby_ui/base.rb", Rails.root.join("app/components/ruby_ui/base.rb")
      end

      private

      def gem_installed?(name)
        Gem::Specification.find_all_by_name(name).any?
      end

      def using_tailwindcss_rails_gem?
        File.exist?(Rails.root.join("app/assets/tailwind/application.css"))
      end
    end
  end
end
