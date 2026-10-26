require "json"

module ShadcnAudit
  # Resolves a PR number, branch or component name to pinned SHAs and the
  # component folders to audit.
  module Target
    REPO = "ruby-ui/ruby_ui".freeze
    SHARED_PATHS = [
      "gem/lib/ruby_ui/base.rb",
      "gem/lib/ruby_ui.rb",
      "docs/app/assets/stylesheets/application.tailwind.css"
    ].freeze
    SHARED_PREFIXES = ["gem/lib/generators/"].freeze
    PR_ARG = /\A#?(\d+)\z/

    def self.resolve(arg, shell:, map:, root: ShadcnAudit.root)
      arg = arg.to_s.strip
      if (match = PR_ARG.match(arg))
        resolve_pr(match[1].to_i, shell: shell, map: map, root: root)
      elsif (folder = component_folder(arg, map))
        resolve_component(folder, shell: shell, root: root)
      else
        resolve_branch(arg, shell: shell, map: map, root: root)
      end
    end

    def self.head_sha_for_pr(number, shell:)
      json = shell.capture("gh", "pr", "view", number.to_s, "--repo", REPO, "--json", "headRefOid")
      JSON.parse(json).fetch("headRefOid")
    end

    def self.resolve_pr(number, shell:, map:, root:)
      json = shell.capture("gh", "pr", "view", number.to_s, "--repo", REPO,
        "--json", "headRefOid,baseRefOid,files,state")
      data = JSON.parse(json)
      shell.capture("git", "fetch", "origin", "refs/pull/#{number}/head", chdir: root)
      files = data.fetch("files").map { |f| f.fetch("path") }
      build("pr", number, data.fetch("baseRefOid"), data.fetch("headRefOid"), files, map)
    end

    def self.resolve_component(folder, shell:, root:)
      sha = shell.capture("git", "rev-parse", "origin/main", chdir: root).strip
      {
        "kind" => "component", "repo" => REPO, "pr" => nil,
        "base_sha" => sha, "head_sha" => sha, "changed_files" => [],
        "components" => [folder], "unmapped" => [],
        "needs_selection" => false, "candidates" => []
      }
    end

    def self.resolve_branch(branch, shell:, map:, root:)
      head = shell.capture("git", "rev-parse", branch, chdir: root).strip
      base = shell.capture("git", "merge-base", "origin/main", branch, chdir: root).strip
      files = shell.capture("git", "diff", "--name-only", "#{base}...#{head}", chdir: root).lines.map(&:strip).reject(&:empty?)
      build("branch", nil, base, head, files, map)
    end

    def self.component_folder(arg, map)
      folder = map.folder_for_name(arg)
      folder if folder && map.all_folders.include?(folder)
    end

    # Every component folder touched, mapped or not: an unmapped one is
    # audited as inconclusive later, so it must not vanish.
    def self.build(kind, pr, base, head, files, map)
      components = files.filter_map { |f| map.component_folder_for_path(f) }.uniq.sort
      unmapped = components - map.all_folders
      needs_selection = components.empty? && files.any? { |f| shared_path?(f) }
      {
        "kind" => kind, "repo" => REPO, "pr" => pr,
        "base_sha" => base, "head_sha" => head, "changed_files" => files,
        "components" => components, "unmapped" => unmapped,
        "needs_selection" => needs_selection,
        "candidates" => needs_selection ? map.all_folders : []
      }
    end

    def self.shared_path?(path)
      SHARED_PATHS.include?(path) || SHARED_PREFIXES.any? { |p| path.start_with?(p) }
    end

    private_class_method :resolve_pr, :resolve_component, :resolve_branch, :component_folder, :build, :shared_path?
  end
end
