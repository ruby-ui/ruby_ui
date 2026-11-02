module ShadcnAudit
  module Drift
    # What changed in shadcn under each mapped component since its baseline
    # (`shadcn_sha` in the component map). Read-only: it never decides
    # whether a divergence covers a change; it attaches the related ones.
    class Runner
      SOURCE_DIFF_LINES = 200
      BASE_UI = "@base-ui/react"
      REPO = "shadcn-ui/ui"
      COMMITS_PER_PAGE = 30

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
        if after["missing"]
          return base.merge("status" => "missing_upstream", "source_diff" => source_diff(baseline, shadcn))
              .merge(commits(baseline, shadcn))
        end

        base_root = @snapshot.materialize(baseline)
        before = reference(base_root, shadcn)
        diff = Diff.compare(before["missing"] ? {} : before, after)
        source = source_diff(baseline, shadcn)
        deps = dependencies(shadcn, before, after, base_root, head_root)
        changed = !Diff.empty?(diff) || !source["diff"].empty? || !deps.empty?
        result = base.merge("status" => changed ? "changed" : "unchanged", "reference" => diff, "dependencies" => deps,
          "source_diff" => source, "commits" => [], "commits_error" => nil, "commits_truncated" => false,
          "related_divergences" => [])
        return result unless changed

        whole = !source["diff"].empty? || !deps.empty? || !diff["variants"].empty? || !diff["warnings_added"].empty?
        result.merge(commits(baseline, shadcn)).merge("related_divergences" => related(folder, diff, whole: whole))
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
          "-f", "since=#{@snapshot.commit_date(baseline)}", "-f", "per_page=#{COMMITS_PER_PAGE}",
          "--jq", '[.[] | {sha, title: (.commit.message | split("\n")[0]), url: .html_url}]')
        page = JSON.parse(json)
        {"commits" => page.reject { |c| c["sha"] == baseline }, "commits_error" => nil,
         "commits_truncated" => page.size >= COMMITS_PER_PAGE}
      rescue Shell::Error, SystemCallError, JSON::ParserError => e
        {"commits" => [], "commits_error" => e.message, "commits_truncated" => false}
      end

      # Parts rendered through another shadcn component (<Button>) get that
      # component's classes at runtime, which Reference leaves out and only
      # warns about. Diff each wrapped component too; keep the changed ones.
      WRAPPED = /rendered through <([A-Z]\w*)>/

      def dependencies(shadcn, before, after, base_root, head_root)
        names = (Array(before["warnings"]) + Array(after["warnings"])).filter_map { |w| w[WRAPPED, 1] }.uniq
        names.filter_map { |name| shadcn_file(name, head_root) || shadcn_file(name, base_root) }.uniq.reject { |dep| dep == shadcn }.sort
          .each_with_object({}) do |dep, out|
            dep_before = reference(base_root, dep)
            dep_after = reference(head_root, dep)
            diff = Diff.compare(dep_before["missing"] ? {} : dep_before, dep_after["missing"] ? {} : dep_after)
            out[dep] = diff unless Diff.empty?(diff)
          end
      end

      # <DropdownMenuItem> lives in dropdown-menu.tsx: drop trailing words
      # until a file exists.
      def shadcn_file(component, root)
        words = component.gsub(/([a-z\d])([A-Z])/, '\1-\2').downcase.split("-")
        words.size.downto(1).map { |n| words.first(n).join("-") }
          .find { |name| root.join("apps/v4/registry", "bases/base/ui/#{name}.tsx").file? }
      end

      # Entries tied to a changed slot through `match.part`, plus every
      # prose entry (no `match`), which only the agent can weigh. A change
      # that can't be pinned to a slot (the .tsx, a wrapped component, a
      # variant, a new scanner warning)
      # relates every entry of the component.
      def related(folder, diff, whole: false)
        return @divergences.for_component(folder) if whole

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
          out[sha] = nil # unknown: the baseline couldn't be read
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
