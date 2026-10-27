require "test_helper"

class WorkspaceTest < Minitest::Test
  SHA = "8f04138777c1b6996e709993362a7b0a12888ecf"

  def setup
    @tmp = Dir.mktmpdir
    @dir = Pathname.new(@tmp)
    @shell = ShadcnAudit::FakeShell.new
    @shell.stub(%w[git rev-parse HEAD], "#{SHA}\n")
    @workspace = ShadcnAudit::Workspace.new(shell: @shell, dir: @dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def test_first_sync_clones_sparse_and_checks_out_main
    result = @workspace.sync

    assert_equal [
      ["git", "clone", "--filter=blob:none", "--sparse", "https://github.com/shadcn-ui/ui.git", "#{@dir}/ui"],
      ["git", "sparse-checkout", "set", "apps/v4/registry", "apps/v4/content/docs/changelog"],
      ["git", "fetch", "--depth", "1", "origin", "main"],
      ["git", "checkout", "--detach", "FETCH_HEAD"],
      ["git", "rev-parse", "HEAD"]
    ], @shell.argvs
    assert_equal({"shadcn_sha" => SHA, "path" => "#{@dir}/ui"}, result)
  end

  def test_existing_clone_skips_clone
    FileUtils.mkdir_p(@dir.join("ui", ".git"))

    @workspace.sync

    refute @shell.argvs.any? { |argv| argv[1] == "clone" }
    assert @shell.called?("git", "fetch", "--depth", "1", "origin", "main")
  end

  def test_existing_clone_reapplies_sparse_paths_before_fetching
    FileUtils.mkdir_p(@dir.join("ui", ".git"))

    @workspace.sync

    sparse = @shell.argvs.index(["git", "sparse-checkout", "set", *ShadcnAudit::Workspace::SPARSE_PATHS])
    fetch = @shell.argvs.index { |argv| argv[1] == "fetch" }
    assert sparse, "sparse-checkout set not run on an existing clone"
    assert_operator sparse, :<, fetch
    assert_equal "#{@dir}/ui", @shell.calls[sparse].chdir
  end

  def test_current_sha_reads_the_existing_clone
    FileUtils.mkdir_p(@dir.join("ui", ".git"))
    assert_equal SHA, @workspace.current_sha
    assert_equal "#{@dir}/ui", @shell.calls.last.chdir
  end

  def test_current_sha_without_a_clone_raises
    assert_raises(ShadcnAudit::ConfigError) { @workspace.current_sha }
    assert_empty @shell.calls
  end

  def test_pinned_sha_fetches_that_sha
    @workspace.sync(sha: SHA)

    assert @shell.called?("git", "fetch", "--depth", "1", "origin", SHA)
  end

  def test_pinned_sync_checks_out_fetch_head_and_returns_rev_parse_output
    short = SHA[0, 8]
    result = @workspace.sync(sha: short)

    fetch = @shell.argvs.index(["git", "fetch", "--depth", "1", "origin", short])
    checkout = @shell.argvs.index(["git", "checkout", "--detach", "FETCH_HEAD"])
    rev_parse = @shell.argvs.index(["git", "rev-parse", "HEAD"])
    assert checkout, "pinned sync must check out FETCH_HEAD detached"
    assert_operator fetch, :<, checkout
    assert_operator checkout, :<, rev_parse
    assert_equal SHA, result["shadcn_sha"], "the returned SHA is rev-parse HEAD's output, not the pin"
  end
end

class RootTest < Minitest::Test
  def test_root_is_repo_root_and_workspace_dir_is_inside_it
    assert ShadcnAudit.root.join("audit", "lib", "shadcn_audit.rb").exist?
    assert_equal ShadcnAudit.root.join(".shadcn-audit"), ShadcnAudit.workspace_dir
  end
end
