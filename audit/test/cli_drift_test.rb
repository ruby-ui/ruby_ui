require "test_helper"

class CliDriftTest < Minitest::Test
  HEAD = "b" * 40

  def setup
    @tmp = Pathname.new(Dir.mktmpdir)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def run_cli(*argv, **deps)
    out = StringIO.new
    status = ShadcnAudit::CLI.run(argv, out: out, **deps)
    [status, JSON.parse(out.string)]
  end

  def test_drift_passes_components_and_head_to_the_runner
    shell = ShadcnAudit::FakeShell.new.stub(%w[git rev-parse HEAD], "#{HEAD}\n")
    received = nil
    factory = lambda do |**kwargs|
      received = kwargs
      Struct.new(:call).new({"head_sha" => kwargs[:head_sha]})
    end

    status, result = run_cli("drift", "--components", "badge,card", "--head", HEAD,
      runner_factory: factory, shell: shell, workspace_dir: @tmp)

    assert_equal 0, status
    assert_equal({"head_sha" => HEAD}, result)
    assert_equal %w[badge card], received[:components]
    assert_equal HEAD, received[:head_sha]
    assert shell.called?("git", "fetch", "--depth", "1", "origin", HEAD)
  end

  def test_drift_without_head_syncs_main_and_all_components
    shell = ShadcnAudit::FakeShell.new.stub(%w[git rev-parse HEAD], "#{HEAD}\n")
    received = nil
    factory = ->(**kwargs) { Struct.new(:call).new({}).tap { received = kwargs } }

    run_cli("drift", runner_factory: factory, shell: shell, workspace_dir: @tmp)

    assert shell.called?("git", "fetch", "--depth", "1", "origin", "main")
    assert_nil received[:components]
  end

  def test_baseline_rejects_unknown_folder
    status, result = run_cli("baseline", "nope", HEAD)

    assert_equal 1, status
    assert_match(/nope/, result["error"])
  end

  def test_baseline_rejects_short_sha
    status, result = run_cli("baseline", "badge", "abc")

    assert_equal 1, status
    assert_match(/40-character/, result["error"])
  end
end
