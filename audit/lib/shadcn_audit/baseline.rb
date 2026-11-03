module ShadcnAudit
  # Writes `shadcn_sha:` into one component map file as a text edit, so the
  # file's comments and layout survive (a YAML round-trip would drop them).
  module Baseline
    SHADCN_LINE = /^shadcn:[^\n]*(?:\n|\z)/
    LINE = /^shadcn_sha:[ \t]*(?<value>[^\s#]*)(?<rest>[^\n]*)$/

    def self.write(path:, sha:)
      raise ConfigError, "shadcn_sha must be a full 40-character commit SHA, got #{sha.inspect}" unless sha.to_s.match?(ComponentMap::SHA)

      path = Pathname.new(path)
      source = path.read
      found = source.match(LINE)
      previous = found && found[:value].delete(%("'))
      updated =
        if found
          source.sub(LINE) { "shadcn_sha: #{sha}#{found[:rest]}" }
        else
          source.match?(SHADCN_LINE) or raise ConfigError, "#{path}: no `shadcn:` line to put shadcn_sha after"
          source.sub(SHADCN_LINE) { |line| "#{line.chomp}\nshadcn_sha: #{sha}\n" }
        end
      path.write(updated)
      {"path" => path.to_s, "shadcn_sha" => sha, "previous" => previous}
    end
  end
end
