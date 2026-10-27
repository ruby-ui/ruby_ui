require "json"

module ShadcnAudit
  # Resolves a PR number, branch or component name to pinned SHAs and the
  # component folders to audit.
  module Target
    REPO = "ruby-ui/ruby_ui".freeze
    # Fetched by URL, never through `origin`: in a fork clone `origin` is the
    # fork, and its main is not upstream's.
    UPSTREAM_URL = "https://github.com/#{REPO}.git".freeze
    MAIN_REF = "refs/shadcn-audit/main".freeze
    MAIN_REFSPEC = "+refs/heads/main:#{MAIN_REF}".freeze
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

    # Current head SHA and state (OPEN, MERGED, CLOSED) of a PR.
    def self.pr_head(number, shell:)
      data = JSON.parse(shell.capture("gh", "pr", "view", number.to_s, "--repo", REPO, "--json", "headRefOid,state"))
      {"head_sha" => data.fetch("headRefOid"), "state" => data["state"]}
    end

    def self.resolve_pr(number, shell:, map:, root:)
      json = shell.capture("gh", "pr", "view", number.to_s, "--repo", REPO,
        "--json", "headRefOid,baseRefOid,files,state,isCrossRepository,headRepositoryOwner")
      data = JSON.parse(json)
      shell.capture("git", "fetch", UPSTREAM_URL, "refs/pull/#{number}/head", MAIN_REFSPEC, chdir: root)
      files = data.fetch("files").map { |f| f.fetch("path") }
      build("pr", number, data.fetch("baseRefOid"), data.fetch("headRefOid"), files, map,
        state: data["state"], cross_repository: cross_repository?(data))
    end

    # A real branch/commit wins over a component name.
    def self.resolve_non_pr(arg, shell:, map:, root:)
      shell.capture("git", "fetch", UPSTREAM_URL, MAIN_REFSPEC, chdir: root)
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
      sha = shell.capture("git", "rev-parse", MAIN_REF, chdir: root).strip
      {
        "kind" => "component", "repo" => REPO, "pr" => nil, "state" => nil, "cross_repository" => false,
        "base_sha" => sha, "head_sha" => sha, "changed_files" => [],
        "components" => [folder], "unmapped" => [],
        "needs_selection" => false, "candidates" => []
      }
    end

    def self.resolve_branch(branch, head, shell:, map:, root:)
      base = shell.capture("git", "merge-base", MAIN_REF, branch, chdir: root).strip
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
    # Head pushed from anywhere but ruby-ui/ruby_ui: its code is untrusted
    # until someone reads what it would execute.
    def self.cross_repository?(data)
      owner = data.dig("headRepositoryOwner", "login")
      data["isCrossRepository"] == true || (!owner.nil? && owner != REPO.split("/").first)
    end

    def self.build(kind, pr, base, head, files, map, state: nil, cross_repository: false)
      components = files.filter_map { |f| map.component_folder_for_path(f) }.uniq.sort
      unmapped = components - map.all_folders
      needs_selection = components.empty? && files.any? { |f| shared_path?(f) }
      {
        "kind" => kind, "repo" => REPO, "pr" => pr, "state" => state, "cross_repository" => cross_repository,
        "base_sha" => base, "head_sha" => head, "changed_files" => files,
        "components" => components, "unmapped" => unmapped,
        "needs_selection" => needs_selection,
        "candidates" => needs_selection ? map.all_folders : []
      }
    end

    def self.shared_path?(path)
      SHARED_PATHS.include?(path) || SHARED_PREFIXES.any? { |p| path.start_with?(p) }
    end

    private_class_method :resolve_pr, :resolve_component, :resolve_non_pr, :verified_commit, :resolve_branch, :component_folder, :cross_repository?, :build, :shared_path?
  end
end
