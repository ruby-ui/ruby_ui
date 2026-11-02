module ShadcnAudit
  module Drift
    # What changed in shadcn under each mapped component since its baseline
    # (`shadcn_sha` in the component map). Read-only: it never decides
    # whether a divergence covers a change; it attaches the related ones.
    class Runner
      SOURCE_DIFF_LINES = 200
      BASE_UI = "@base-ui/react"
      REPO = "shadcn-ui/ui"

      def initialize(map:, divergences:, snapshot:, shell:, head_sha:, rubyui_css:, components: nil)
        @map = map
        @divergences = divergences
        @snapshot = snapshot
        @shell = shell
        @head_sha = head_sha
        @rubyui_css = rubyui_css
        @components = components
      end

      def call
        folders = selected_folders
        head_root = @snapshot.materialize(@head_sha)
        components = folders.to_h { |folder| [folder, component(folder, head_root)] }
        {
          "head_sha" => @head_sha,
          "theme" => theme(head_root),
          "base_ui" => base_ui(head_root, folders),
          "components" => components
        }
      end

      private

      def selected_folders
        all = @map.all_folders.sort
        return all unless @components

        unknown = @components - all
        raise ArgumentError, "not in audit/component_map/: #{unknown.join(", ")}" unless unknown.empty?
        @components
      end

      def component(folder, head_root)
        shadcn = @map.entry(folder)["shadcn"]
        baseline = @map.shadcn_sha(folder)
        return {"status" => "no_counterpart", "shadcn" => nil} if shadcn.nil?
        return {"status" => "no_baseline", "shadcn" => shadcn, "baseline_sha" => nil} if baseline.nil?

        base = {"shadcn" => shadcn, "baseline_sha" => baseline}
        after = reference(head_root, shadcn)
        return base.merge("status" => "missing_upstream") if after["missing"]

        before = reference(@snapshot.materialize(baseline), shadcn)
        diff = Diff.compare(before["missing"] ? {} : before, after)
        source = source_diff(baseline, shadcn)
        changed = !Diff.empty?(diff) || !source["diff"].empty?
        result = base.merge("status" => changed ? "changed" : "unchanged", "reference" => diff, "source_diff" => source,
          "commits" => [], "commits_error" => nil, "related_divergences" => [])
        return result unless changed

        result.merge(commits(baseline, shadcn)).merge("related_divergences" => related(folder, diff))
      # Unattended weekly runs degrade per component: any failure here (git,
      # a Reference parser gap on new TSX, a missing binary) costs one entry,
      # never the whole report.
      rescue Shell::Error, ConfigError => e
        {"status" => "inconclusive", "shadcn" => shadcn, "baseline_sha" => baseline, "reason" => e.message}
      rescue => e
        {"status" => "inconclusive", "shadcn" => shadcn, "baseline_sha" => baseline, "reason" => "#{e.class}: #{e.message}"}
      end

      def reference(root, shadcn) = Reference.new(registry_dir: root.join("apps/v4/registry")).for(shadcn)

      def tsx_path(shadcn) = "apps/v4/registry/bases/base/ui/#{shadcn}.tsx"

      def source_diff(baseline, shadcn)
        lines = @snapshot.diff(baseline, @head_sha, tsx_path(shadcn)).lines
        {"path" => tsx_path(shadcn), "diff" => lines.first(SOURCE_DIFF_LINES).join, "truncated" => lines.size > SOURCE_DIFF_LINES}
      end

      def commits(baseline, shadcn)
        json = @shell.capture("gh", "api", "-X", "GET", "repos/#{REPO}/commits",
          "-f", "path=#{tsx_path(shadcn)}", "-f", "sha=#{@head_sha}",
          "-f", "since=#{@snapshot.commit_date(baseline)}", "-f", "per_page=30",
          "--jq", '[.[] | {sha, title: (.commit.message | split("\n")[0]), url: .html_url}]')
        {"commits" => JSON.parse(json).reject { |c| c["sha"] == baseline }, "commits_error" => nil}
      rescue Shell::Error, SystemCallError, JSON::ParserError => e
        {"commits" => [], "commits_error" => e.message}
      end

      # Entries tied to a changed slot through `match.part`, plus every
      # prose entry (no `match`), which only the agent can weigh.
      def related(folder, diff)
        slots = diff["classes"].keys | diff["parts_added"] | diff["parts_removed"]
        parts = @map.entry(folder)["parts"] || {}
        @divergences.for_component(folder).select do |entry|
          match = entry["match"]
          match.nil? || slots.include?(parts[match["part"]])
        end
      end

      def theme(head_root)
        Theme.compare(themes_ts: head_root.join("apps/v4/registry/themes.ts"), rubyui_css: @rubyui_css)
      rescue ArgumentError, Errno::ENOENT => e
        {"status" => "inconclusive", "reason" => e.message}
      end

      def base_ui(head_root, folders)
        baselines = folders.filter_map { |f| @map.shadcn_sha(f) if @map.entry(f)["shadcn"] }.uniq.sort
        versions = baselines.each_with_object({}) do |sha, out|
          out[sha] = base_ui_version(@snapshot.materialize(sha))
        rescue Shell::Error, ConfigError
          next
        end
        {"head" => base_ui_version(head_root), "baselines" => versions}
      end

      def base_ui_version(root)
        package = JSON.parse(root.join("apps/v4/package.json").read)
        package.dig("dependencies", BASE_UI) || package.dig("devDependencies", BASE_UI)
      rescue Errno::ENOENT, JSON::ParserError
        nil
      end
    end
  end
end
