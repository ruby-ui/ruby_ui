require "rails/generators"

module RubyUI
  module Generators
    class BaseGenerator < defined?(Rails::Generators::Base) ? Rails::Generators::Base : Object
      namespace "ruby_ui:base"

      source_root File.join(__dir__, "templates")

      private

      def using_importmap?
        File.exist?(Rails.root.join("config/importmap.rb")) && File.exist?(Rails.root.join("bin/importmap"))
      end
    end
  end
end
