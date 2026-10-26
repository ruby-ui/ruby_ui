require "fileutils"

module ShadcnAudit
  # RubyUI repo extracted at an exact commit (the audited PR head) with a
  # dev-only route that renders audit/fixtures/*/rubyui.rb inside the docs
  # app. The docs app loads the gem via `path: "../gem"`, so the archive's own
  # gem/ is what renders. Uses `git archive`, never a worktree, so the main
  # working tree is left alone.
  class RubyuiPreview
    URL_TEMPLATE = "http://localhost:3179/__audit/{folder}?theme={light|dark}"
    SHA = /\A[0-9a-f]{7,40}\z/
    FULL_SHA = /\A[0-9a-f]{40}\z/
    FIXTURES_TARGET = "docs/app/views/shadcn_audit_fixtures"

    def initialize(shell:, dir:, root: ShadcnAudit.root, audit_dir: ShadcnAudit.root.join("audit"), platform: Gem::Platform.local.to_s)
      @shell = shell
      @dir = Pathname.new(dir)
      @root = Pathname.new(root)
      @audit_dir = Pathname.new(audit_dir)
      @platform = platform
    end

    # Run in <checkout>/docs. The docs lockfile may list only `ruby` and
    # x86_64-linux, which makes Bundler build native gems (nokogiri) from
    # source; adding the host platform picks the precompiled ones. It edits
    # only the throwaway checkout's lockfile, never gem versions.
    def boot
      [
        "mise exec -- bundle lock --add-platform #{@platform}",
        "mise exec -- bundle install",
        "pnpm install",
        "pnpm build",
        "pnpm build:css",
        "mise exec -- bin/rails db:prepare",
        "mise exec -- bin/rails server -p 3179"
      ]
    end

    def prepare(sha)
      full_sha = resolve(sha)
      path = @dir.join("checkouts", full_sha)
      extract(full_sha, path) unless path.directory?
      copy_overlay(path)
      copy_fixtures(path)
      {"path" => path.to_s, "url_template" => URL_TEMPLATE, "boot" => boot, "boot_chdir" => path.join("docs").to_s}
    end

    private

    def resolve(sha)
      raise ConfigError, "not a commit SHA: #{sha.inspect} (expected 7-40 lowercase hex chars)" unless SHA.match?(sha.to_s)
      begin
        @shell.capture("git", "cat-file", "-e", "#{sha}^{commit}", chdir: @root)
      rescue Shell::Error => e
        raise ConfigError, "commit #{sha} is unknown or ambiguous in the local repo (git: #{e.message.lines.first.to_s.strip}); " \
          "pass the full SHA, or run `target <pr>` first to fetch it"
      end
      full_sha = @shell.capture("git", "rev-parse", "--verify", "#{sha}^{commit}", chdir: @root).strip
      return full_sha if FULL_SHA.match?(full_sha)
      raise ConfigError, "git rev-parse resolved #{sha} to #{full_sha.inspect}, not a full 40-char SHA"
    end

    # Extracts into a sibling staging dir and renames it, so an interrupted
    # extraction is never mistaken for a reusable checkout.
    def extract(sha, path)
      staging = Pathname.new("#{path}.partial")
      tarball = Pathname.new("#{path}.tar")
      FileUtils.rm_rf([staging, tarball])
      FileUtils.mkdir_p(staging)
      @shell.capture("git", "archive", "--format=tar", "-o", tarball.to_s, sha, chdir: @root)
      @shell.capture("tar", "-x", "-f", tarball.to_s, "-C", staging.to_s)
      File.rename(staging, path)
    ensure
      FileUtils.rm_f(tarball) if tarball
      FileUtils.rm_rf(staging) if staging
    end

    def copy_overlay(path)
      overlay = @audit_dir.join("preview_overlay")
      Dir.glob("**/*", base: overlay.to_s).each do |relative|
        source = overlay.join(relative)
        next unless source.file?
        target = path.join(relative)
        FileUtils.mkdir_p(target.dirname)
        FileUtils.cp(source, target)
      end
    end

    def copy_fixtures(path)
      target = path.join(FIXTURES_TARGET)
      FileUtils.rm_rf(target)
      FileUtils.mkdir_p(target)
      Dir[@audit_dir.join("fixtures/*/rubyui.rb").to_s].each do |source|
        FileUtils.cp(source, target.join("#{File.basename(File.dirname(source))}.rb"))
      end
    end
  end
end
