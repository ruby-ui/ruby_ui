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
      else
        resolve_non_pr(arg, shell: shell, map: map, root: root)
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
      build("pr", number, data.fetch("baseRefOid"), data.fetch("headRefOid"), files, map, state: data["state"])
    end

    # A real branch/commit wins over a component name.
    def self.resolve_non_pr(arg, shell:, map:, root:)
      shell.capture("git", "fetch", "origin", "main", chdir: root)
      head = verified_commit(arg, shell, root)
      return resolve_branch(arg, head, shell: shell, map: map, root: root) if head

      folder = component_folder(arg, map)
      raise ArgumentError, "#{arg.inspect} is not a PR number, branch or known component" unless folder

      resolve_component(folder, shell: shell, root: root)
    end

    def self.verified_commit(arg, shell, root)
      sha = shell.capture("git", "rev-parse", "--verify", "--quiet", "#{arg}^{commit}", chdir: root).strip
      sha.empty? ? nil : sha
    rescue Shell::Error
      nil
    end

    def self.resolve_component(folder, shell:, root:)
      sha = shell.capture("git", "rev-parse", "origin/main", chdir: root).strip
      {
        "kind" => "component", "repo" => REPO, "pr" => nil, "state" => nil,
        "base_sha" => sha, "head_sha" => sha, "changed_files" => [],
        "components" => [folder], "unmapped" => [],
        "needs_selection" => false, "candidates" => []
      }
    end

    def self.resolve_branch(branch, head, shell:, map:, root:)
      base = shell.capture("git", "merge-base", "origin/main", branch, chdir: root).strip
      files = shell.capture("git", "diff", "--name-only", "#{base}...#{head}", chdir: root).lines.map(&:strip).reject(&:empty?)
      build("branch", nil, base, head, files, map)
    end

    # Exact matches only: folder, its CamelCase form, or a mapped part name.
    def self.component_folder(arg, map)
      folder = map.folder_for_name(arg)
      return unless folder && map.all_folders.include?(folder)

      snake = arg.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      part = (map.entry(folder) || {}).fetch("parts", nil) || {}
      folder if [arg, snake].include?(folder) || part.key?(arg)
    end

    # Every component folder touched, mapped or not: an unmapped one is
    # audited as inconclusive later, so it must not vanish.
    def self.build(kind, pr, base, head, files, map, state: nil)
      components = files.filter_map { |f| map.component_folder_for_path(f) }.uniq.sort
      unmapped = components - map.all_folders
      needs_selection = components.empty? && files.any? { |f| shared_path?(f) }
      {
        "kind" => kind, "repo" => REPO, "pr" => pr, "state" => state,
        "base_sha" => base, "head_sha" => head, "changed_files" => files,
        "components" => components, "unmapped" => unmapped,
        "needs_selection" => needs_selection,
        "candidates" => needs_selection ? map.all_folders : []
      }
    end

    def self.shared_path?(path)
      SHARED_PATHS.include?(path) || SHARED_PREFIXES.any? { |p| path.start_with?(p) }
    end

    private_class_method :resolve_pr, :resolve_component, :resolve_non_pr, :verified_commit, :resolve_branch, :component_folder, :build, :shared_path?
  end
end
