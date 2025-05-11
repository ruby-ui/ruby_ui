module RubyUI
  module Generators
    module Component
      class AllGenerator < Rails::Generators::Base
        namespace "ruby_ui:component:all"

        source_root File.expand_path("../../../ruby_ui", __dir__)

        def generate_components
          say "Generating all components..."

          Dir.children(self.class.source_root).each do |folder_name|
            puts "folder_name: #{folder_name}"
            next if folder_name == "base.rb"

            component_name = folder_name.camelize
            run "bin/rails generate ruby_ui:component #{component_name} --force true"
          end
        end
      end
    end
  end
end
