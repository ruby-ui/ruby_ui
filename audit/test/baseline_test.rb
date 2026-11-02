require "test_helper"

class BaselineTest < Minitest::Test
  OLD = "a" * 40
  NEW = "b" * 40

  def setup
    @tmp = Pathname.new(Dir.mktmpdir)
    @dir = @tmp.join("component_map")
    FileUtils.mkdir_p(@dir)
    @path = @dir.join("badge.yml")
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def test_baseline_replaces_an_existing_line
    @path.write("shadcn: badge\nshadcn_sha: #{OLD}\nkind: static\n")

    result = ShadcnAudit::Baseline.write(path: @path, sha: NEW)

    assert_equal "shadcn: badge\nshadcn_sha: #{NEW}\nkind: static\n", @path.read
    assert_equal({"path" => @path.to_s, "shadcn_sha" => NEW, "previous" => OLD}, result)
  end

  def test_baseline_inserts_after_the_shadcn_line_keeping_comments
    @path.write("shadcn: badge\nkind: static\nprops:\n  # keep me\n  Badge: {variant: variant}\n")

    result = ShadcnAudit::Baseline.write(path: @path, sha: NEW)

    assert_equal "shadcn: badge\nshadcn_sha: #{NEW}\nkind: static\nprops:\n  # keep me\n  Badge: {variant: variant}\n", @path.read
    assert_nil result["previous"]
    assert_equal NEW, ShadcnAudit::ComponentMap.load(@dir).shadcn_sha("badge")
  end

  def test_baseline_rejects_a_short_sha
    @path.write("shadcn: badge\n")

    assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Baseline.write(path: @path, sha: "abc") }
    assert_equal "shadcn: badge\n", @path.read
  end

  def test_baseline_needs_a_shadcn_line
    @path.write("kind: static\n")

    assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Baseline.write(path: @path, sha: NEW) }
  end

  def test_baseline_keeps_a_trailing_comment
    @path.write("shadcn: badge\nshadcn_sha: #{OLD} # audited in #600\n")

    result = ShadcnAudit::Baseline.write(path: @path, sha: NEW)

    assert_equal "shadcn: badge\nshadcn_sha: #{NEW} # audited in #600\n", @path.read
    assert_equal OLD, result["previous"]
  end
end
