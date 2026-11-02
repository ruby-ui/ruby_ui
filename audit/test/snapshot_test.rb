require "test_helper"

class SnapshotTest < Minitest::Test
  SHA = "8f04138777c1b6996e709993362a7b0a12888ecf"

  def setup
    @tmp = Dir.mktmpdir
    @dir = Pathname.new(@tmp)
    FileUtils.mkdir_p(@dir.join("ui/.git"))
    @shell = ShadcnAudit::FakeShell.new
    @snapshot = ShadcnAudit::Snapshot.new(shell: @shell, dir: @dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def tar_path = @dir.join("snapshots", "#{SHA}.tar")

  def test_materialize_fetches_archives_and_extracts
    root = @snapshot.materialize(SHA)

    assert_equal @dir.join("snapshots", SHA), root
    assert @shell.called?("git", "fetch", "--depth", "1", "origin", SHA)
    archive = @shell.argvs.find { |a| a[0, 2] == %w[git archive] }
    assert_equal ["--format=tar", "--output=#{tar_path}", SHA, *ShadcnAudit::Snapshot::PATHS], archive[2..]
    tar = @shell.argvs.find { |a| a.first == "tar" }
    assert_equal ["tar", "-xf", tar_path.to_s, "-C", @dir.join("snapshots", "#{SHA}.tmp").to_s], tar
    assert_equal "#{@dir}/ui", @shell.calls.find { |c| c.argv[0, 2] == %w[git fetch] }.chdir
  end

  def test_materialize_reuses_an_existing_snapshot
    FileUtils.mkdir_p(@dir.join("snapshots", SHA, "apps/v4"))

    @snapshot.materialize(SHA)

    assert_empty @shell.argvs
  end

  def test_materialize_rejects_a_short_sha
    assert_raises(ShadcnAudit::ConfigError) { @snapshot.materialize("abc") }
  end

  def test_materialize_needs_the_workspace_clone
    FileUtils.rm_rf(@dir.join("ui"))

    error = assert_raises(ShadcnAudit::ConfigError) { @snapshot.materialize(SHA) }
    assert_match(/run `workspace` first/, error.message)
  end

  def test_materialize_leaves_no_partial_snapshot_when_fetch_fails
    @shell.stub_error(->(a) { a[0, 2] == %w[git fetch] }, "not our ref")

    assert_raises(ShadcnAudit::Shell::Error) { @snapshot.materialize(SHA) }
    refute @dir.join("snapshots", SHA).exist?
    refute @dir.join("snapshots", "#{SHA}.tmp").exist?
  end

  def test_commit_date_and_diff_run_in_the_clone
    @shell.stub(["git", "show", "-s", "--format=%cI", SHA], "2026-10-30T10:00:00Z\n")
    @shell.stub(["git", "diff", SHA, "b" * 40, "--", "apps/x.tsx"], "+new\n")

    assert_equal "2026-10-30T10:00:00Z", @snapshot.commit_date(SHA)
    assert_equal "+new\n", @snapshot.diff(SHA, "b" * 40, "apps/x.tsx")
    assert(@shell.calls.all? { |c| c.chdir == "#{@dir}/ui" })
  end
end
