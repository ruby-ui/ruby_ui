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
          docs_src = read_docs_source(dir, slug)
          parsed = parse_docs_source(docs_src)
          docs_md = parsed[:markdown]
          examples = parsed[:examples]
          {
            name: name,
            description: extract_description(files, docs_src, docs_md),
            files: files,
            dependencies: {
              components: Array(dep_entry["components"]),
              js_packages: Array(dep_entry["js_packages"]),
              gems: Array(dep_entry["gems"])
            },
            install_command: "rails g ruby_ui:component #{name}",
            docs_markdown: docs_md,
            examples: examples
          }
        end

        def camelize(slug)
          slug.split("_").map(&:capitalize).join
        end

        def read_docs_source(dir, slug)
          docs_file = File.join(dir, "#{slug}_docs.rb")
          File.exist?(docs_file) ? File.read(docs_file) : ""
        end

        # Single-pass parser: returns {markdown: String, examples: Array}
        def parse_docs_source(src)
          return {markdown: "", examples: []} if src.empty?

          lines = src.lines
          markdown = +""
          examples = []
          i = 0

          while i < lines.length
            line = lines[i]

            # Docs::Header.new(title: "X", description: "Y")
            if (m = line.match(/Docs::Header\.new\(([^)]*)\)/))
              args = m[1]
              title = extract_kwarg(args, "title")
              desc = extract_kwarg(args, "description")
              markdown << "# #{title}\n\n" if title
              markdown << "#{desc}\n\n" if desc
              i += 1
              next
            end

            # Heading(level: N) { "X" }
            if (m = line.match(/Heading\(level:\s*(\d+)\)\s*\{\s*"([^"]+)"\s*\}/))
              level = [m[1].to_i, 6].min
              markdown << "#{"#" * level} #{m[2]}\n\n"
              i += 1
              next
            end

            # P { "X" } or p { "X" } (standalone paragraph)
            if (m = line.match(/\bP\s*\{\s*"([^"]+)"\s*\}/) || line.match(/\bp\s*\{\s*"([^"]+)"\s*\}/))
              markdown << "#{m[1]}\n\n"
              i += 1
              next
            end

            # VisualCodeExample.new(...)
            if line.match(/VisualCodeExample\.new\(/)
              # collect full invocation (may span multiple lines until closing paren + do)
              invocation = +line
              j = i
              while j < lines.length && !invocation.match(/\bdo\b/)
                j += 1
                break if j >= lines.length
                invocation << lines[j]
              end

              title = extract_kwarg(invocation, "title")

              # find heredoc opener on following lines
              k = j + 1
              heredoc_lang = nil
              while k < lines.length
                if (hm = lines[k].match(/<<~([A-Z]+)/))
                  heredoc_lang = hm[1]
                  k += 1
                  break
                end
                # stop searching if we hit end / another render call
                break if lines[k].match(/^\s*end\b/) && !lines[k].match(/<<~/)
                k += 1
              end

              if heredoc_lang
                # accumulate heredoc body
                body_lines = []
                while k < lines.length
                  break if lines[k].match(/^\s*#{Regexp.escape(heredoc_lang)}\s*$/)
                  body_lines << lines[k]
                  k += 1
                end
                # strip common leading whitespace (squiggly heredoc)
                code = dedent(body_lines)
                lang = heredoc_lang.downcase == "ruby" ? "ruby" : heredoc_lang.downcase

                examples << {title: title, code: code, language: lang}

                if title
                  markdown << "### #{title}\n\n"
                end
                markdown << "```#{lang}\n#{code}```\n\n"

                i = k + 1
                next
              end

              i = j + 1
              next
            end

            i += 1
          end

          {markdown: markdown.strip, examples: examples}
        end

        def extract_kwarg(str, key)
          # handles: key: "value" or key: 'value'
          if (m = str.match(/#{Regexp.escape(key)}:\s*["']([^"']+)["']/))
            m[1]
          end
        end

        def dedent(lines)
          return "" if lines.empty?
          # find minimum indentation (ignore blank lines)
          non_blank = lines.reject { |l| l.strip.empty? }
          return lines.join if non_blank.empty?
          min_indent = non_blank.map { |l| l.match(/^(\s*)/)[1].length }.min
          lines.map { |l| l.length >= min_indent ? l[min_indent..] : l }.join
        end

        def extract_description(files, docs_src, docs_md)
          # prefer description from Docs::Header
          if (m = docs_src.match(/Docs::Header\.new\(([^)]*)\)/m))
            desc = extract_kwarg(m[1], "description")
            return desc if desc
          end
          if (m = docs_md.match(/^# .+?\n+([^\n#].+)/m))
            m[1].strip
          elsif files.first && (m = files.first[:content].match(/^#\s*(?:RubyUI::\w+\s*[—-]\s*)?(.+)$/))
            m[1].strip
          else
            ""
          end
        end
      end
    end
  end
end
