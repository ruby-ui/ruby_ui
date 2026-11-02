require "yaml"

module ShadcnAudit
  # Registry of intentional RubyUI-vs-shadcn differences.
  class Divergences
    DIMENSIONS = %w[Look HTML Props ARIA Behavior Animation Native].freeze
    REQUIRED = %w[component rubyui shadcn reason].freeze

    DIR = "divergences"
    LEGACY_FILE = "divergences.yml"

    # The registry of an audit/ folder: one file per component in
    # audit/divergences/<folder>.yml. Checkouts from before the split still
    # have the single audit/divergences.yml, so that is the fallback.
    def self.for_audit(audit_dir)
      audit_dir = Pathname.new(audit_dir)
      dir = audit_dir.join(DIR)
      dir.directory? ? load(dir) : load(audit_dir.join(LEGACY_FILE))
    end

    # Where a component's entries live, relative to the repo root.
    def self.path_for(folder) = "audit/#{DIR}/#{folder}.yml"

    # A directory of <folder>.yml files, or a single YAML list.
    def self.load(path)
      path = Pathname.new(path)
      return new(path.exist? ? YAML.safe_load_file(path.to_s) || [] : []) unless path.directory?

      entries = path.glob("*.yml").sort.flat_map do |file|
        list = YAML.safe_load_file(file.to_s) || []
        raise ConfigError, "#{DIR}/#{file.basename}: must be a list of entries" unless list.is_a?(Array)

        folder = file.basename(".yml").to_s
        list.each do |entry|
          next unless entry.is_a?(Hash) && entry["component"] != folder

          raise ConfigError, "#{DIR}/#{file.basename}: entry for #{entry["component"].inspect} belongs in #{DIR}/#{entry["component"]}.yml"
        end
        list
      end
      new(entries)
    end

    def initialize(entries)
      raise ConfigError, "divergences.yml must be a list of entries" unless entries.is_a?(Array)
      @entries = entries
      validate!
    end

    def find(component:, dimension:)
      @entries.find { |e| e["component"] == component.to_s && e["dimension"] == dimension.to_s }
    end

    # Entry whose structured `match` describes exactly this difference.
    # Prose-only entries never match: reading them is the agent's call.
    def match(component:, dimension:, part:, key:, rubyui:, shadcn:)
      @entries.find do |e|
        m = e["match"]
        next false unless m && e["component"] == component.to_s && e["dimension"] == dimension.to_s
        m["part"] == part.to_s && (m["property"] || m["attribute"]) == key.to_s &&
          same?(dimension, m["rubyui"], rubyui) && same?(dimension, m["shadcn"], shadcn)
      end
    end

    def for_component(component)
      @entries.select { |e| e["component"] == component.to_s }
    end

    def suggest(component:, dimension:, rubyui:, shadcn:)
      entry = {
        "component" => component,
        "dimension" => dimension,
        "rubyui" => rubyui,
        "shadcn" => shadcn,
        "reason" => "TODO",
        "since" => Time.now.strftime("%Y-%m-%d")
      }
      YAML.dump([entry]).delete_prefix("---\n")
    end

    private

    MATCH_KEYS = {"Look" => "property", "ARIA" => "attribute"}.freeze

    # Look values are normalized CSS; ARIA values (snapshots, attributes) are exact.
    def same?(dimension, expected, actual)
      return expected.to_s == actual.to_s unless dimension.to_s == "Look"

      Collect::Normalize.value(expected) == Collect::Normalize.value(actual)
    end

    def validate_match!(label, entry)
      m = entry["match"]
      return if m.nil?
      raise ConfigError, "#{label}: match is only for Look or ARIA" unless MATCH_KEYS.key?(entry["dimension"])

      key = MATCH_KEYS[entry["dimension"]]
      other = (MATCH_KEYS.values - [key]).first
      raise ConfigError, "#{label}: #{entry["dimension"]} match needs #{key}" if m.is_a?(Hash) && !m.key?(key) && m.key?(other)
      raise ConfigError, "#{label}: #{entry["dimension"]} match must use #{key} only" if m.is_a?(Hash) && m.key?(other)
      complete = m.is_a?(Hash) && %w[part rubyui shadcn].all? { |k| m.key?(k) && !m[k].nil? } && !m[key].to_s.strip.empty?
      raise ConfigError, "#{label}: match needs part, property|attribute, rubyui and shadcn" unless complete
    end

    def validate!
      @entries.each_with_index do |entry, i|
        raise ConfigError, "divergences.yml: entry ##{i + 1} must be a mapping" unless entry.is_a?(Hash)

        label = "divergences.yml: #{entry["component"] || "entry ##{i + 1}"} / #{entry["dimension"].inspect}"
        REQUIRED.each do |key|
          raise ConfigError, "#{label}: missing #{key}" if entry[key].to_s.strip.empty?
        end
        raise ConfigError, "#{label}: reason is still TODO" if entry["reason"].to_s.strip.casecmp?("TODO")
        raise ConfigError, "#{label}: unknown dimension (expected one of #{DIMENSIONS.join(" ")})" unless DIMENSIONS.include?(entry["dimension"])
        validate_match!(label, entry)
      end
    end
  end
end
