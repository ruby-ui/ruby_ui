require "json"

module ShadcnAudit
  class ReportError < StandardError; end

  # The report.json the skill writes, validated on load so renderers can
  # trust its shape.
  class Report
    STATUSES = %w[pass warn fail inconclusive].freeze
    DIMENSIONS = %w[Look HTML Props ARIA Behavior Animation Native Spec].freeze
    BASES = %w[intentional native spec].freeze
    TOP_KEYS = %w[target shadcn_sha sandbox_lock environment_diffs theme components].freeze
    TARGET_KEYS = %w[repo base_sha head_sha].freeze
    LINE_KEYS = %w[dimension status].freeze

    attr_reader :data

    def self.load(path)
      new(JSON.parse(File.read(path)))
    rescue JSON::ParserError => e
      raise ReportError, "report is not valid JSON: #{e.message}"
    end

    def initialize(data)
      @data = data
      validate!
    end

    def target = data["target"]

    def shadcn_sha = data["shadcn_sha"]

    def environment_diffs = data["environment_diffs"]

    def theme = data["theme"]

    def components = data["components"]

    def header
      {
        "repo" => target["repo"], "pr" => target["pr"],
        "base_sha" => target["base_sha"], "head_sha" => target["head_sha"],
        "shadcn_sha" => shadcn_sha
      }
    end

    private

    def validate!
      raise ReportError, "report must be a JSON object" unless data.is_a?(Hash)
      missing = TOP_KEYS - data.keys
      raise ReportError, "report is missing: #{missing.join(", ")}" unless missing.empty?
      raise ReportError, "target must be an object" unless target.is_a?(Hash)
      blank = TARGET_KEYS.reject { |key| target[key].is_a?(String) && !target[key].strip.empty? }
      raise ReportError, "target is missing: #{blank.join(", ")}" unless blank.empty?
      raise ReportError, "sandbox_lock must be an object" unless data["sandbox_lock"].is_a?(Hash)
      raise ReportError, "environment_diffs must be an array" unless environment_diffs.is_a?(Array)
      raise ReportError, "theme must be an object with diffs" unless theme.is_a?(Hash) && theme["diffs"].is_a?(Array)
      raise ReportError, "theme diffs must be objects" unless theme["diffs"].all?(Hash)
      raise ReportError, "components must be an array" unless components.is_a?(Array)
      components.each { |component| validate_component!(component) }
    end

    def validate_component!(component)
      folder = component["folder"] if component.is_a?(Hash)
      raise ReportError, "component folder must be a non-empty string" unless folder.is_a?(String) && !folder.strip.empty?
      raise ReportError, "#{folder}: lines must be an array" unless component["lines"].is_a?(Array)
      component["lines"].each { |line| validate_line!(folder, line) }
      Array(component["screenshots"]).each do |shot|
        next if shot.is_a?(Hash) && %w[state rubyui shadcn].all? { |k| shot[k].is_a?(String) }
        raise ReportError, "#{folder}: screenshot needs state, rubyui and shadcn"
      end
    end

    def validate_line!(folder, line)
      raise ReportError, "#{folder}: line must be an object" unless line.is_a?(Hash)
      where = "#{folder} #{line["dimension"]}"
      raise ReportError, "#{where}: unknown dimension" unless DIMENSIONS.include?(line["dimension"])
      raise ReportError, "#{where}: unknown status #{line["status"].inspect}" unless STATUSES.include?(line["status"])
      basis = line["basis"]
      raise ReportError, "#{where}: unknown basis #{basis.inspect}" unless basis.nil? || BASES.include?(basis)
      raise ReportError, "#{where}: basis only allowed on a pass line" if basis && line["status"] != "pass"
      source = line["source"].to_s.strip
      status = line["status"]
      raise ReportError, "#{where}: #{status} line needs a source" if status != "inconclusive" && source.empty?
      http = source.match?(%r{\Ahttps?://})
      spec_finding = line["dimension"] == "Spec" && %w[fail warn].include?(status)
      raise ReportError, "#{where}: spec finding needs an http source" if spec_finding && !http
      raise ReportError, "#{where}: pass with basis spec needs an http source" if basis == "spec" && !http
    end
  end
end
