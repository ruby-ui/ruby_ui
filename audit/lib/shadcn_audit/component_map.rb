require "yaml"

module ShadcnAudit
  class ConfigError < StandardError; end

  # Maps RubyUI component folders to their shadcn counterparts.
  class ComponentMap
    KINDS = %w[modal menu popover disclosure form_control static].freeze
    COMPONENT_NAME = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
    SHA = /\A[0-9a-f]{40}\z/
    PATH_PATTERNS = [
      %r{\Agem/lib/ruby_ui/([^/]+)/},
      %r{\Agem/test/ruby_ui/([^/]+)_test\.rb\z},
      %r{\Adocs/app/views/docs/([^/]+)\.rb\z}
    ].freeze

    DIR = "component_map"
    LEGACY_FILE = "component_map.yml"

    # The map of an audit/ folder: one file per component in
    # audit/component_map/<folder>.yml. Checkouts from before the split still
    # have the single audit/component_map.yml, so that is the fallback.
    def self.for_audit(audit_dir)
      audit_dir = Pathname.new(audit_dir)
      dir = audit_dir.join(DIR)
      dir.directory? ? load(dir) : load(audit_dir.join(LEGACY_FILE))
    end

    # Where a component's entry lives, relative to the repo root.
    def self.path_for(folder) = "audit/#{DIR}/#{folder}.yml"

    # A directory of <folder>.yml files, or a single YAML keyed by folder.
    def self.load(path)
      path = Pathname.new(path)
      return new(YAML.safe_load_file(path.to_s) || {}) unless path.directory?

      files = path.glob("*.yml").sort
      folders = files.map { |file| file.basename(".yml").to_s }
      new(
        folders.zip(files.map { |file| YAML.safe_load_file(file.to_s) }).to_h,
        folders.to_h { |folder| [folder, "#{DIR}/#{folder}.yml"] }
      )
    end

    def initialize(entries, sources = nil)
      @entries = entries
      @sources = sources
      validate!
    end

    def entry(folder) = @entries[folder.to_s]

    def all_folders = @entries.keys

    # shadcn commit the component was last matched against (nil = no baseline).
    def shadcn_sha(folder) = (entry(folder) || {})["shadcn_sha"]

    # RubyUI part => CSS selector in the rendered fixture ({} when unset).
    # A null selector means "not compared" (e.g. a Base UI root with no DOM).
    def selectors(folder) = (entry(folder) || {})["selectors"] || {}

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

    # Contents for audit/component_map/<folder>.yml.
    def suggest_entry(folder)
      stub = {
        "shadcn" => folder.tr("_", "-"),
        "kind" => "TODO",
        "docs_view" => folder,
        "parts" => {},
        "props" => {}
      }
      YAML.dump(stub).delete_prefix("---\n")
    end

    private

    def validate_selectors!(folder, entry)
      selectors = entry["selectors"]
      return if selectors.nil?
      raise ConfigError, "#{where(folder)}: selectors must be a mapping" unless selectors.is_a?(Hash)

      parts = entry["parts"] || {}
      selectors.each do |part, css|
        raise ConfigError, "#{where(folder)}: selectors.#{part} is not a mapped part" unless parts[part]
        next if css.nil? || (css.is_a?(String) && !css.strip.empty?)

        raise ConfigError, "#{where(folder)}: selectors.#{part} must be a non-empty CSS selector"
      end
    end

    # "component_map/dialog.yml" for a split map, "component_map.yml: dialog" for a single file.
    def where(folder) = @sources ? @sources.fetch(folder) : "#{LEGACY_FILE}: #{folder}"

    def snake_case(name)
      name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end

    def validate!
      @entries.each do |folder, entry|
        raise ConfigError, "#{where(folder)}: entry must be a mapping" unless entry.is_a?(Hash)

        kind = entry["kind"]
        unless kind.nil? || KINDS.include?(kind)
          raise ConfigError, "#{where(folder)}: unknown kind #{kind.inspect} (expected one of #{KINDS.join(", ")})"
        end

        (entry["rubyui_only"] || {}).each do |part, kwargs|
          next if kwargs.is_a?(Array)

          raise ConfigError, "#{where(folder)}: rubyui_only.#{part} must be an array of kwargs"
        end

        validate_selectors!(folder, entry)

        sha = entry["shadcn_sha"]
        if !sha.nil? && !(sha.is_a?(String) && sha.match?(SHA))
          raise ConfigError, "#{where(folder)}: shadcn_sha must be a full 40-character commit SHA"
        end

        extra = entry["fixture_shadcn"]
        if !extra.nil? && !(extra.is_a?(Array) && extra.all? { |name| name.is_a?(String) && name.match?(COMPONENT_NAME) })
          raise ConfigError, "#{where(folder)}: fixture_shadcn must be an array of shadcn component names"
        end
      end
    end
  end
end
