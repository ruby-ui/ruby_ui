require "test_helper"

class DriftRunnerTest < Minitest::Test
  BASE = "a" * 40
  HEAD = "b" * 40
  REGISTRY = File.expand_path("../fixtures/registry", __dir__)
  CSS = File.expand_path("../fixtures/application.tailwind.css", __dir__)
  BADGE = "apps/v4/registry/bases/base/ui/badge.tsx"

  class FakeSnapshot
    attr_reader :calls
    attr_accessor :source_diff

    def initialize(trees)
      @trees = trees
      @calls = []
      @source_diff = ""
    end

    def materialize(sha)
      @calls << [:materialize, sha]
      @trees.fetch(sha) { raise ShadcnAudit::Shell::Error, "fatal: couldn't find remote ref #{sha}" }
    end

    def commit_date(sha)
      @calls << [:commit_date, sha]
      "2026-10-30T10:00:00Z"
    end

    def diff(from, to, path)
      @calls << [:diff, from, to, path]
      @source_diff
    end
  end

  def setup
    @tmp = Pathname.new(Dir.mktmpdir)
    @base = tree("base", base_ui: "1.5.0")
    @head = tree("head", base_ui: "1.6.0")
    @snapshot = FakeSnapshot.new(BASE => @base, HEAD => @head)
    @shell = ShadcnAudit::FakeShell.new
    @map = ShadcnAudit::ComponentMap.new({
      "badge" => {"shadcn" => "badge", "shadcn_sha" => BASE, "parts" => {"Badge" => "badge"}},
      "aspect_ratio" => {"shadcn" => nil},
      "card" => {"shadcn" => "card"}
    })
    @divergences = ShadcnAudit::Divergences.new([
      {"component" => "badge", "dimension" => "Look", "rubyui" => "r", "shadcn" => "s", "reason" => "why",
       "match" => {"part" => "Badge", "property" => "width", "rubyui" => "100%", "shadcn" => "fit-content"}},
      {"component" => "badge", "dimension" => "Behavior", "rubyui" => "r", "shadcn" => "s", "reason" => "prose"},
      {"component" => "badge", "dimension" => "Look", "rubyui" => "r", "shadcn" => "s", "reason" => "other part",
       "match" => {"part" => "BadgeIcon", "property" => "width", "rubyui" => "1", "shadcn" => "2"}}
    ])
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def tree(name, base_ui:)
    root = @tmp.join(name)
    FileUtils.mkdir_p(root.join("apps/v4"))
    FileUtils.cp_r(REGISTRY, root.join("apps/v4/registry"))
    root.join("apps/v4/package.json").write(JSON.generate("dependencies" => {"@base-ui/react" => base_ui}))
    root
  end

  def edit_head_badge
    path = @head.join(BADGE)
    yield path, path.read
  end

  def run_drift(components: nil, map: @map)
    ShadcnAudit::Drift::Runner.new(map: map, divergences: @divergences, snapshot: @snapshot, shell: @shell,
      head_sha: HEAD, rubyui_css: CSS, components: components).call
  end

  def gh_commits(json)
    @shell.stub(->(argv) { argv[0, 2] == %w[gh api] }, json)
  end

  def test_changed_component_reports_reference_and_source_diff
    edit_head_badge { |path, src| path.write(src.sub("inline-flex w-fit", "inline-flex w-full")) }
    @snapshot.source_diff = "-w-fit\n+w-full\n"
    gh_commits(JSON.generate([{"sha" => HEAD, "title" => "fix badge", "url" => "u"}, {"sha" => BASE, "title" => "old", "url" => "o"}]))

    badge = run_drift(components: ["badge"])["components"]["badge"]

    assert_equal "changed", badge["status"]
    assert_equal BASE, badge["baseline_sha"]
    assert_equal({"added" => ["w-full"], "removed" => ["w-fit"]}, badge["reference"]["classes"]["badge"])
    assert_equal({"path" => BADGE, "diff" => "-w-fit\n+w-full\n", "truncated" => false}, badge["source_diff"])
    assert_equal [{"sha" => HEAD, "title" => "fix badge", "url" => "u"}], badge["commits"]
    assert_nil badge["commits_error"]
  end

  def test_commits_query_uses_path_head_and_baseline_date
    edit_head_badge { |path, src| path.write(src.sub("w-fit", "w-full")) }
    gh_commits("[]")

    run_drift(components: ["badge"])

    argv = @shell.argvs.find { |a| a[0, 2] == %w[gh api] }
    assert_includes argv, "repos/shadcn-ui/ui/commits"
    assert_includes argv, "path=#{BADGE}"
    assert_includes argv, "sha=#{HEAD}"
    assert_includes argv, "since=2026-10-30T10:00:00Z"
  end

  def test_related_divergences_are_changed_parts_plus_prose
    edit_head_badge { |path, src| path.write(src.sub("w-fit", "w-full")) }
    gh_commits("[]")

    reasons = run_drift(components: ["badge"])["components"]["badge"]["related_divergences"].map { |d| d["reason"] }

    assert_equal ["why", "prose"], reasons
  end

  def test_unchanged_component_skips_gh
    badge = run_drift(components: ["badge"])["components"]["badge"]

    assert_equal "unchanged", badge["status"]
    assert_empty badge["commits"]
    assert_empty badge["related_divergences"]
    assert_empty @shell.argvs
  end

  def test_source_diff_alone_marks_changed
    @snapshot.source_diff = "+  aria-label\n"
    gh_commits("[]")

    assert_equal "changed", run_drift(components: ["badge"])["components"]["badge"]["status"]
  end

  def test_source_diff_is_truncated_at_200_lines
    @snapshot.source_diff = (1..250).map { |i| "+line #{i}\n" }.join
    gh_commits("[]")

    diff = run_drift(components: ["badge"])["components"]["badge"]["source_diff"]

    assert_equal 200, diff["diff"].lines.size
    assert diff["truncated"]
  end

  def test_no_counterpart_and_no_baseline_never_touch_snapshot_or_shell
    result = run_drift(components: %w[aspect_ratio card])["components"]

    assert_equal "no_counterpart", result["aspect_ratio"]["status"]
    assert_equal "no_baseline", result["card"]["status"]
    assert_empty @snapshot.calls.reject { |c| c == [:materialize, HEAD] }
    assert_empty @shell.argvs
  end

  def test_tsx_missing_at_head_is_missing_upstream
    @head.join(BADGE).delete

    assert_equal "missing_upstream", run_drift(components: ["badge"])["components"]["badge"]["status"]
  end

  def test_unfetchable_baseline_is_inconclusive_and_others_still_run
    map = ShadcnAudit::ComponentMap.new({
      "badge" => {"shadcn" => "badge", "shadcn_sha" => "c" * 40, "parts" => {"Badge" => "badge"}},
      "button" => {"shadcn" => "button", "shadcn_sha" => BASE, "parts" => {"Button" => "button"}}
    })

    result = run_drift(map: map)["components"]

    assert_equal "inconclusive", result["badge"]["status"]
    assert_match(/couldn't find remote ref/, result["badge"]["reason"])
    assert_equal "unchanged", result["button"]["status"]
  end

  def test_gh_failure_fills_commits_error
    edit_head_badge { |path, src| path.write(src.sub("w-fit", "w-full")) }
    @shell.stub_error(->(argv) { argv[0, 2] == %w[gh api] }, "HTTP 403: rate limit")

    badge = run_drift(components: ["badge"])["components"]["badge"]

    assert_equal "changed", badge["status"]
    assert_empty badge["commits"]
    assert_match(/rate limit/, badge["commits_error"])
  end

  def test_new_reference_warning_marks_changed
    edit_head_badge { |path, src| path.write(src + "\n// cn-orphan-token\n") }
    gh_commits("[]")

    badge = run_drift(components: ["badge"])["components"]["badge"]

    assert_equal "changed", badge["status"]
    refute_empty badge["reference"]["warnings_added"]
  end

  def test_global_head_theme_and_base_ui
    result = run_drift(components: ["badge"])

    assert_equal HEAD, result["head_sha"]
    assert_includes %w[pass fail], result["theme"]["status"]
    assert_equal({"head" => "1.6.0", "baselines" => {BASE => "1.5.0"}}, result["base_ui"])
  end

  def test_unknown_component_filter_raises
    error = assert_raises(ArgumentError) { run_drift(components: ["nope"]) }
    assert_match(/nope/, error.message)
  end

  def test_missing_gh_binary_fills_commits_error
    edit_head_badge { |path, src| path.write(src.sub("w-fit", "w-full")) }
    @shell.stub(->(argv) { argv[0, 2] == %w[gh api] }, Errno::ENOENT.new("gh"))

    badge = run_drift(components: ["badge"])["components"]["badge"]

    assert_equal "changed", badge["status"]
    assert_match(/gh/, badge["commits_error"])
  end

  def test_unexpected_error_in_one_component_is_inconclusive_and_others_still_run
    map = ShadcnAudit::ComponentMap.new({
      "badge" => {"shadcn" => "badge", "shadcn_sha" => BASE, "parts" => {"Badge" => "badge"}},
      "button" => {"shadcn" => "button", "shadcn_sha" => BASE, "parts" => {"Button" => "button"}}
    })
    def @snapshot.diff(from, to, path)
      raise NoMethodError, "boom" if path.end_with?("badge.tsx")
      ""
    end

    result = run_drift(map: map)["components"]

    assert_equal "inconclusive", result["badge"]["status"]
    assert_equal "NoMethodError: boom", result["badge"]["reason"]
    assert_equal "unchanged", result["button"]["status"]
  end
end
