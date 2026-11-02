module ShadcnAudit
  # Writes `shadcn_sha:` into one component map file as a text edit, so the
  # file's comments and layout survive (a YAML round-trip would drop them).
  module Baseline
    LINE = /^shadcn_sha:[^\n]*$/

    def self.write(path:, sha:)
      raise ConfigError, "shadcn_sha must be a full 40-character commit SHA, got #{sha.inspect}" unless sha.to_s.match?(ComponentMap::SHA)

      path = Pathname.new(path)
      source = path.read
      previous = source[LINE]&.split(":", 2)&.last&.strip
      updated =
        if previous
          source.sub(LINE, "shadcn_sha: #{sha}")
        else
          source.match?(/^shadcn:[^\n]*\n/) or raise ConfigError, "#{path}: no `shadcn:` line to put shadcn_sha after"
          source.sub(/^shadcn:[^\n]*\n/) { |line| "#{line}shadcn_sha: #{sha}\n" }
        end
      path.write(updated)
      {"path" => path.to_s, "shadcn_sha" => sha, "previous" => previous}
    end
  end
end
