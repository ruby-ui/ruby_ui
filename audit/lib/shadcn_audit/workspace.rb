require "fileutils"

module ShadcnAudit
  # Local sparse clone of shadcn-ui/ui used as the audit's upstream source.
  class Workspace
    REPO_URL = "https://github.com/shadcn-ui/ui.git"
    SPARSE_PATHS = %w[apps/v4/registry apps/v4/content/docs/changelog].freeze

    def initialize(shell:, dir:)
      @shell = shell
      @dir = Pathname.new(dir)
    end

    # The sparse paths are re-applied on every sync: a clone left half-set
    # (interrupted, or an older path list) would otherwise lack registry
    # files, and a missing file reads as "no shadcn equivalent".
    def sync(sha: nil)
      # git fetch can't resolve abbreviated object names against the remote.
      raise ConfigError, "--sha needs the full 40-character commit SHA, got #{sha.inspect}" if sha && !sha.match?(/\A[0-9a-f]{40}\z/)
      clone_repo unless clone_dir.join(".git").exist?
      @shell.capture("git", "sparse-checkout", "set", *SPARSE_PATHS, chdir: clone_dir)
      @shell.capture("git", "fetch", "--depth", "1", "origin", sha || "main", chdir: clone_dir)
      @shell.capture("git", "checkout", "--detach", "FETCH_HEAD", chdir: clone_dir)
      head = @shell.capture("git", "rev-parse", "HEAD", chdir: clone_dir).strip
      {"shadcn_sha" => head, "path" => clone_dir.to_s}
    end

    # SHA checked out in the existing clone; the sandbox uses it as a refresh trigger.
    def current_sha
      raise ConfigError, "no shadcn workspace at #{clone_dir}; run `workspace` first" unless clone_dir.join(".git").exist?
      @shell.capture("git", "rev-parse", "HEAD", chdir: clone_dir).strip
    end

    private

    def clone_dir = @dir.join("ui")

    def clone_repo
      FileUtils.mkdir_p(@dir)
      @shell.capture("git", "clone", "--filter=blob:none", "--sparse", REPO_URL, clone_dir.to_s)
    end
  end
end
