require "yaml"

module ShadcnAudit
  class ConfigError < StandardError; end

  # Maps RubyUI component folders to their shadcn counterparts.
  class ComponentMap
    KINDS = %w[modal menu popover disclosure form_control static].freeze
    PATH_PATTERNS = [
      %r{\Agem/lib/ruby_ui/([^/]+)/},
      %r{\Agem/test/ruby_ui/([^/]+)_test\.rb\z},
      %r{\Adocs/app/views/docs/([^/]+)\.rb\z}
    ].freeze

    def self.load(path)
      new(YAML.safe_load_file(path.to_s) || {})
    end

    def initialize(entries)
      @entries = entries
      validate!
    end

    def entry(folder) = @entries[folder.to_s]

    def all_folders = @entries.keys

    # Folder for a component path, only when it is in the map.
    def folder_for_path(path)
      folder = component_folder_for_path(path)
      folder if folder && @entries.key?(folder)
    end

    # Folder for a component path, mapped or not.
    def component_folder_for_path(path)
      PATH_PATTERNS.each do |pattern|
        match = pattern.match(path.to_s)
        return match[1] if match
      end
      nil
    end

    # Accepts a RubyUI class name (CamelCase) or a snake_case name.
    def folder_for_name(name)
      name = name.to_s
      return name if @entries.key?(name)

      by_part = @entries.find { |_, e| (e["parts"] || {}).key?(name) }
      return by_part.first if by_part

      snake = snake_case(name)
      return snake if @entries.key?(snake)

      all_folders.select { |f| snake.start_with?("#{f}_") }.max_by(&:length)
    end

    def suggest_entry(folder)
      stub = {
        folder => {
          "shadcn" => folder.tr("_", "-"),
          "kind" => "TODO",
          "docs_view" => folder,
          "parts" => {},
          "props" => {}
        }
      }
      YAML.dump(stub).delete_prefix("---\n")
    end

    private

    def snake_case(name)
      name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end

    def validate!
      @entries.each do |folder, entry|
        kind = entry["kind"]
        next if kind.nil? || KINDS.include?(kind)

        raise ConfigError, "component_map.yml: #{folder}: unknown kind #{kind.inspect} (expected one of #{KINDS.join(", ")})"
      end
    end
  end
end
