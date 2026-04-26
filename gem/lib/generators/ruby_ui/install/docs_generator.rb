# frozen_string_literal: true

require "rails/generators"

module RubyUI
  module Generators
    module Install
      class DocsGenerator < Rails::Generators::Base
        namespace "ruby_ui:install:docs"
        source_root File.expand_path("../../../ruby_ui", __dir__)
        class_option :force, type: :boolean, default: false

        def copy_docs_files
          say "Installing RubyUI documentation files..."

          docs_file_paths.each do |source_path|
            dest_filename = File.basename(source_path).sub("_docs", "")
            copy_file source_path, Rails.root.join("app/views/docs", dest_filename), force: options["force"]
          end

          say ""
          say "Documentation installed to app/views/docs/", :green
        end

        private

        def docs_file_paths
          Dir.glob(File.join(self.class.source_root, "*", "*_docs.rb"))
        end
      end
    end
  end
end
