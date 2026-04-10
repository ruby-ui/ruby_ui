# frozen_string_literal: true

module RubyUI
  module Generators
    # Engine-aware file selection for component generation.
    #
    # Supports three engines:
    #   phlex (default) — copies .rb files, excludes templates and _docs files.
    #   erb  — copies .rb + .html.erb templates; for non-herb components falls back to phlex.
    #   herb — same files as erb, but also installs the herb gem in the consumer app.
    module EngineUtils
      module_function

      # Returns true if the component directory contains a Herb template (.html.erb).
      def herb_component?(component_dir)
        herb_template_paths(component_dir).any?
      end

      # Returns paths to all Herb templates (.html.erb) in the component directory.
      def herb_template_paths(component_dir)
        Dir.glob(File.join(component_dir, "*.html.erb"))
      end

      # Returns the files to copy for the given engine.
      #
      # @param component_dir [String] path to the component source directory
      # @param engine [String]        "phlex", "erb", or "herb"
      # @param with_docs [Boolean]    whether to include _docs files
      # @return [Array<String>] file paths
      def component_files_for_engine(component_dir, engine:, with_docs: false)
        case engine.to_s
        when "erb", "herb"
          erb_component_files(component_dir, with_docs: with_docs)
        else
          phlex_component_files(component_dir, with_docs: with_docs)
        end
      end

      # Files for --engine=phlex (default).
      # Copies plain .rb files; excludes _phlex.rb artifacts and _docs.rb.
      def phlex_component_files(component_dir, with_docs: false)
        files = Dir.glob(File.join(component_dir, "*.rb"))
        files = files.reject { |f| f.end_with?("_phlex.rb") }
        files = files.reject { |f| f.end_with?("_docs.rb") } unless with_docs
        files
      end

      # Files for --engine=erb / --engine=herb.
      # For herb-migrated components: .rb class + .html.erb template.
      # Optionally includes _docs.html.erb when with_docs is true.
      # For non-herb components: falls back to phlex file selection.
      def erb_component_files(component_dir, with_docs: false)
        if herb_component?(component_dir)
          rb_files = Dir.glob(File.join(component_dir, "*.rb"))
          rb_files = rb_files.reject { |f| f.end_with?("_phlex.rb", "_docs.rb") }
          templates = herb_template_paths(component_dir)
          templates = templates.reject { |f| f.end_with?("_docs.html.erb") } unless with_docs
          rb_files + templates
        else
          phlex_component_files(component_dir, with_docs: with_docs)
        end
      end
    end
  end
end
