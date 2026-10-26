require "yaml"

module ShadcnAudit
  # Registry of intentional RubyUI-vs-shadcn differences.
  class Divergences
    DIMENSIONS = %w[Look HTML Props ARIA Behavior Animation Native].freeze

    def self.load(path)
      entries = File.exist?(path.to_s) ? YAML.safe_load_file(path.to_s) : nil
      new(entries || [])
    end

    def initialize(entries)
      @entries = entries
      validate!
    end

    def find(component:, dimension:)
      @entries.find { |e| e["component"] == component.to_s && e["dimension"] == dimension.to_s }
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

    def validate!
      @entries.each_with_index do |entry, i|
        label = "divergences.yml: #{entry["component"] || "entry ##{i + 1}"} / #{entry["dimension"].inspect}"
        raise ConfigError, "#{label}: missing reason" if entry["reason"].to_s.strip.empty?
        raise ConfigError, "#{label}: unknown dimension (expected one of #{DIMENSIONS.join(" ")})" unless DIMENSIONS.include?(entry["dimension"])
      end
    end
  end
end
