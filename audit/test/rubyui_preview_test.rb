require "test_helper"

class RubyuiPreviewTest < Minitest::Test
  AUDIT_DIR = ShadcnAudit.root.join("audit")
  SHA = "a9a5d1faee2257e8e83c144a5be88c378347640d"
  FOLDERS = %w[dialog alert_dialog sheet command].freeze

  def setup
    @tmp = Dir.mktmpdir
    @dir = Pathname.new(@tmp)
    @checkout = @dir.join("checkouts", SHA)
    @shell = ShadcnAudit::FakeShell.new
    @shell.stub(->(argv) { argv.first(2) == %w[git rev-parse] }, "#{SHA}\n")
    @preview = ShadcnAudit::RubyuiPreview.new(shell: @shell, dir: @dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def archive_call = @shell.calls.find { |call| call.argv.first(2) == %w[git archive] }

  def test_archives_exact_sha
    result = @preview.prepare("a9a5d1fa")

    assert @shell.called?("git", "cat-file", "-e", "a9a5d1fa^{commit}")
    archive = archive_call
    assert_equal SHA, archive.argv.last
    assert_equal ShadcnAudit.root.to_s, archive.chdir
    tarball = archive.argv[archive.argv.index("-o") + 1]
    tar = @shell.calls.find { |call| call.argv.first == "tar" }
    assert_equal ["tar", "-x", "-f", tarball, "-C"], tar.argv.first(5)
    assert_equal @checkout.to_s, result["path"]
    assert_equal "http://localhost:3179/__audit/{folder}?theme={light|dark}", result["url_template"]
    refute_includes @shell.argvs.flatten, "worktree"
  end

  def test_missing_commit_says_to_run_target
    @shell.stub_error(->(argv) { argv.first(2) == %w[git cat-file] }, "fatal: Not a valid object name")

    error = assert_raises(ShadcnAudit::ConfigError) { @preview.prepare(SHA) }
    assert_match(/run `target/, error.message)
    assert_nil archive_call
  end

  def test_rejects_non_sha
    assert_raises(ShadcnAudit::ConfigError) { @preview.prepare("main") }
    assert_raises(ShadcnAudit::ConfigError) { @preview.prepare("A9A5D1FA") }
    assert_empty @shell.calls
  end

  def test_overlay_and_fixtures_copied
    @preview.prepare(SHA)

    overlay = AUDIT_DIR.join("preview_overlay")
    files = Dir.glob("**/*", base: overlay.to_s).select { |path| overlay.join(path).file? }
    refute_empty files
    files.each do |path|
      assert_equal overlay.join(path).read, @checkout.join(path).read, path
    end
    FOLDERS.each do |folder|
      assert_equal AUDIT_DIR.join("fixtures", folder, "rubyui.rb").read,
        @checkout.join("docs/app/views/shadcn_audit_fixtures/#{folder}.rb").read
    end
  end

  def test_existing_checkout_is_reused
    @preview.prepare(SHA)
    fixture = @checkout.join("docs/app/views/shadcn_audit_fixtures/dialog.rb")
    fixture.write("stale")

    @preview.prepare(SHA)

    assert_equal 1, @shell.argvs.count { |argv| argv.first(2) == %w[git archive] }
    assert_equal AUDIT_DIR.join("fixtures/dialog/rubyui.rb").read, fixture.read
  end

  def test_boot_commands_in_order
    result = @preview.prepare(SHA)

    assert_equal [
      "mise exec -- bundle install",
      "pnpm install",
      "pnpm build",
      "pnpm build:css",
      "mise exec -- bin/rails db:prepare",
      "mise exec -- bin/rails server -p 3179"
    ], result["boot"]
    assert_equal @checkout.join("docs").to_s, result["boot_chdir"]
  end
end
