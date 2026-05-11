# frozen_string_literal: true

require "yaml"
require "time"
require "json"
require "fileutils"

module RubyUI
  module MCP
    module Builders
      class RegistryBuilder
        SKIP_DIRS = %w[docs].freeze
        SKIP_FILES = %w[base.rb].freeze

        def initialize(gem_path:)
          @gem_path = gem_path
        end

        def build
          {
            version: read_version,
            generated_at: (ENV["SOURCE_DATE_EPOCH"] ? Time.at(ENV["SOURCE_DATE_EPOCH"].to_i).utc : Time.now.utc).iso8601,
            components: components_hash
          }
        end

        def write(path)
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, JSON.pretty_generate(build) + "\n")
        end

        private

        def read_version
          candidates = [
            File.join(@gem_path, "lib/ruby_ui/version.rb"),
            File.join(@gem_path, "lib/ruby_ui.rb")
          ]
          candidates.each do |path|
            next unless File.exist?(path)
            src = File.read(path)
            if (m = src.match(/VERSION\s*=\s*["']([^"']+)["']/))
              return m[1]
            end
          end
          "unknown"
        rescue
          "unknown"
        end

        def components_hash
          deps = load_deps
          base_dir = File.join(@gem_path, "lib/ruby_ui")
          Dir.children(base_dir)
            .select { |d| File.directory?(File.join(base_dir, d)) }
            .reject { |d| SKIP_DIRS.include?(d) }
            .sort
            .each_with_object({}) { |d, h| h[d.to_sym] = build_component(d, deps[d] || {}) }
        end

        def load_deps
          path = File.join(@gem_path, "lib/generators/ruby_ui/dependencies.yml")
          File.exist?(path) ? YAML.safe_load_file(path) || {} : {}
        end

        def build_component(slug, dep_entry)
          dir = File.join(@gem_path, "lib/ruby_ui", slug)
          files = Dir.glob(File.join(dir, "*"))
            .reject { |f| SKIP_FILES.include?(File.basename(f)) }
            .reject { |f| File.basename(f).end_with?("_docs.rb") }
            .sort
            .map { |f| {path: File.basename(f), content: File.read(f)} }
          name = camelize(slug)
          docs_md = render_docs_markdown(dir, slug)
          {
            name: name,
            description: extract_description(files, docs_md),
            files: files,
            dependencies: {
              components: Array(dep_entry["components"]),
              js_packages: Array(dep_entry["js_packages"]),
              gems: Array(dep_entry["gems"])
            },
            install_command: "rails g ruby_ui:component #{name}",
            docs_markdown: docs_md,
            examples: extract_examples(docs_md)
          }
        end

        def camelize(slug)
          slug.split("_").map(&:capitalize).join
        end

        def render_docs_markdown(dir, slug)
          docs_file = File.join(dir, "#{slug}_docs.rb")
          return "" unless File.exist?(docs_file)
          src = File.read(docs_file)
          headings = src.scan(/h1\s*\{\s*"([^"]+)"\s*\}/).flatten.map { |t| "# #{t}" }
          paras = src.scan(/p\s*\{\s*"([^"]+)"\s*\}/).flatten
          (headings + paras).join("\n\n")
        end

        def extract_description(files, docs_md)
          if (m = docs_md.match(/^# .+?\n+([^\n#].+)/m))
            m[1].strip
          elsif files.first && (m = files.first[:content].match(/^#\s*(?:RubyUI::\w+\s*[—-]\s*)?(.+)$/))
            m[1].strip
          else
            ""
          end
        end

        def extract_examples(_docs_md)
          [] # phase 1: empty; populated later via VisualCodeExample parser
        end
      end
    end
  end
end
