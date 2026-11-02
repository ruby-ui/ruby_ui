require "fileutils"

module ShadcnAudit
  # Read-only copies of the shadcn files `drift` compares, at any commit.
  # Old commits are fetched into the Workspace's sparse clone and exported
  # with `git archive`, so no second clone is needed.
  class Snapshot
    PATHS = %w[
      apps/v4/registry/bases/base/ui
      apps/v4/registry/styles
      apps/v4/registry/themes.ts
      apps/v4/package.json
    ].freeze

    def initialize(shell:, dir:)
      @shell = shell
      @dir = Pathname.new(dir)
    end

    # Snapshot root for `sha`; the registry is root.join("apps/v4/registry").
    # Extraction goes to <sha>.tmp and is renamed only on success, so a
    # failed run never leaves a half snapshot that later reads as a cache hit.
    def materialize(sha)
      raise ConfigError, "shadcn_sha must be a full 40-character commit SHA, got #{sha.inspect}" unless sha.to_s.match?(ComponentMap::SHA)

      root = snapshots_dir.join(sha)
      return root if root.join("apps/v4").directory?

      check_clone!
      tmp = snapshots_dir.join("#{sha}.tmp")
      tar = snapshots_dir.join("#{sha}.tar")
      FileUtils.rm_rf(tmp)
      FileUtils.mkdir_p(tmp)
      begin
        git("fetch", "--depth", "1", "origin", sha)
        git("archive", "--format=tar", "--output=#{tar}", sha, *PATHS)
        @shell.capture("tar", "-xf", tar.to_s, "-C", tmp.to_s)
        FileUtils.rm_rf(root)
        FileUtils.mv(tmp, root)
      ensure
        FileUtils.rm_rf(tmp)
        FileUtils.rm_f(tar)
      end
      root
    end

    # Committer date (ISO 8601) of a commit already fetched.
    def commit_date(sha) = git("show", "-s", "--format=%cI", sha).strip

    # Unified diff of one path between two fetched commits ("" when equal).
    def diff(from, to, path) = git("diff", from, to, "--", path)

    private

    def snapshots_dir = @dir.join("snapshots")

    def clone_dir = @dir.join("ui")

    def git(*args) = @shell.capture("git", *args, chdir: clone_dir)

    def check_clone!
      return if clone_dir.join(".git").exist?

      raise ConfigError, "no shadcn workspace at #{clone_dir}; run `workspace` first"
    end
  end
end
