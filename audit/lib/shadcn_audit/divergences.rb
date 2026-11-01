require "yaml"

module ShadcnAudit
  # Registry of intentional RubyUI-vs-shadcn differences.
  class Divergences
    DIMENSIONS = %w[Look HTML Props ARIA Behavior Animation Native].freeze
    REQUIRED = %w[component rubyui shadcn reason].freeze

    def self.load(path)
      entries = File.exist?(path.to_s) ? YAML.safe_load_file(path.to_s) : nil
      new(entries || [])
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
          same?(m["rubyui"], rubyui) && same?(m["shadcn"], shadcn)
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

    def same?(expected, actual) = expected.to_s.strip == actual.to_s.strip

    def validate_match!(label, entry)
      m = entry["match"]
      return if m.nil?
      raise ConfigError, "#{label}: match is only for Look or ARIA" unless MATCH_KEYS.key?(entry["dimension"])

      key = MATCH_KEYS[entry["dimension"]]
      raise ConfigError, "#{label}: #{entry["dimension"]} match needs #{key}" if m.is_a?(Hash) && !m.key?(key) && m.key?((MATCH_KEYS.values - [key]).first)
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
