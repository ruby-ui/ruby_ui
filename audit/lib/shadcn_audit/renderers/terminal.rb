module ShadcnAudit
  module Renderers
    # Checklist as plain text (design §A). `body` is shared with Markdown.
    module Terminal
      SYMBOLS = {"pass" => "✅", "warn" => "⚠️", "fail" => "❌", "inconclusive" => "⏸"}.freeze
      BASIS_LABELS = {"intentional" => "intentional", "native" => "native", "spec" => "follows spec"}.freeze
      LABEL_WIDTH = 10

      def self.render(report)
        [header(report), body(report)].join("\n") + "\n"
      end

      def self.short(sha) = sha.to_s[0, 8]

      def self.header(report)
        h = report.header
        pr = h["pr"] ? "PR ##{h["pr"]}  " : ""
        "shadcn audit  #{pr}#{h["repo"]}\n  base #{short(h["base_sha"])}  head #{short(h["head_sha"])}  shadcn #{short(h["shadcn_sha"])}"
      end

      def self.body(report)
        out = report.environment_diffs.map { |diff| "⚠️ Environment  #{diff}" }
        out << theme_line(report.theme)
        report.components.each { |component| out.concat(component_block(component, report.shadcn_sha)) }
        out.join("\n")
      end

      def self.theme_line(theme)
        diffs = theme["diffs"]
        return "✅ Theme  neutral tokens match shadcn" if diffs.empty?

        lines = ["❌ Theme  #{diffs.size} token diff#{"s" if diffs.size != 1} vs shadcn neutral"]
        diffs.each do |d|
          lines << "     #{d["mode"]} --#{d["token"]}: rubyui #{d["rubyui"] || "(missing)"}  shadcn #{d["shadcn"]}"
        end
        lines
      end

      def self.component_block(component, shadcn_sha)
        title = camelize(component["folder"])
        ref = component["shadcn_file"] ? "  (ref: #{component["shadcn_file"]} @ #{short(shadcn_sha)})" : "  (no shadcn equivalent)"
        [title + ref] + component["lines"].flat_map { |line| line_rows(line) }
      end

      def self.line_rows(line)
        prefix = "  #{SYMBOLS.fetch(line["status"])} #{line["dimension"].ljust(LABEL_WIDTH)}"
        indent = " " * (4 + LABEL_WIDTH + 1)
        first = [line["rubyui"], basis_suffix(line)].compact.reject { |s| s.to_s.empty? }.join(" ")
        first = line["note"].to_s if first.empty?
        rows = ["#{prefix} #{first}".rstrip]
        rows << "#{indent}vega: #{line["shadcn"]}" if line["status"] != "pass" && !line["shadcn"].to_s.empty?
        rows << "#{indent}#{line["note"]}" if !line["note"].to_s.empty? && line["note"] != first
        rows << "#{indent}↳ #{line["source"]}" unless line["status"] == "pass" || line["source"].to_s.empty?
        rows
      end

      def self.basis_suffix(line)
        "— #{BASIS_LABELS.fetch(line["basis"])}" if line["basis"]
      end

      def self.camelize(folder) = folder.split("_").map(&:capitalize).join
    end
  end
end
