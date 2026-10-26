require "test_helper"

class RenderersTest < Minitest::Test
  FIXTURE = File.expand_path("fixtures/report_572.json", __dir__)

  def report = ShadcnAudit::Report.load(FIXTURE)

  def test_terminal_has_checklist_content
    text = ShadcnAudit::Renderers::Terminal.render(report)
    ["Dialog", "AlertDialog", "❌ Look", "vega: p-6 gap-6 ring-1", "⏸", "a9a5d1fa", "ddcff1c6", "8f041387", "PR #572",
      "— intentional", "— native", "✅ Look", "⚠️ Animation", "developer.mozilla.org", "↳ audit/divergences.yml"].each do |needle|
      assert_includes text, needle
    end
  end

  def test_environment_and_theme_come_before_components
    text = ShadcnAudit::Renderers::Terminal.render(report)
    env = text.index("⚠️ Environment")
    theme = text.index("❌ Theme")
    component = text.index("Dialog  (ref:")
    assert env < theme && theme < component
    assert_includes text, "--chart-5"
  end

  def test_theme_line_passes_when_no_diffs
    d = JSON.parse(File.read(FIXTURE))
    d["theme"] = {"status" => "pass", "diffs" => []}
    assert_includes ShadcnAudit::Renderers::Terminal.render(ShadcnAudit::Report.new(d)), "✅ Theme"
  end

  def test_markdown_starts_with_marker_and_fences_checklist
    md = ShadcnAudit::Renderers::Markdown.render(report)
    assert md.start_with?("<!-- shadcn-audit -->\n")
    assert_includes md, "❌ Theme"
    assert_includes md, "`a9a5d1fa`"
    assert_includes md, "`ruby-ui/ruby_ui`"
    assert_includes md, "↳ style-vega.css:462"
    assert_equal 2, md.scan(/^```$/).size
  end

  def test_html_lists_dialog_only_and_escapes
    Dir.mktmpdir do |dir|
      d = JSON.parse(File.read(FIXTURE))
      d["components"].first["lines"][1]["rubyui"] = "<script>alert(1)</script>"
      path = ShadcnAudit::Renderers::Html.render(ShadcnAudit::Report.new(d), out_dir: dir)
      html = File.read(path)
      assert_equal File.join(dir, "report.html"), path
      assert_includes html, "Dialog"
      assert_includes html, "screens/dialog-closed-rubyui.png"
      refute_includes html, "AlertDialog"
      refute_includes html, "<script>alert"
      assert_includes html, "&lt;script&gt;"
    end
  end

  def test_html_skips_component_whose_lines_all_pass_and_returns_nil_when_empty
    Dir.mktmpdir do |dir|
      d = JSON.parse(File.read(FIXTURE))
      d["components"] = [{"folder" => "badge", "shadcn_file" => nil,
                          "lines" => [{"dimension" => "Look", "status" => "pass", "basis" => nil, "rubyui" => "x", "shadcn" => "x", "source" => "a:1", "note" => ""}],
                          "screenshots" => [{"state" => "closed", "rubyui" => "a.png", "shadcn" => "b.png"}]}]
      assert_nil ShadcnAudit::Renderers::Html.render(ShadcnAudit::Report.new(d), out_dir: dir)
      refute File.exist?(File.join(dir, "report.html"))
    end
  end

  def test_cli_render_returns_text_and_html_path
    Dir.mktmpdir do |dir|
      FileUtils.cp(FIXTURE, File.join(dir, "report.json"))
      result = ShadcnAudit::CLI::COMMANDS["render"].call([File.join(dir, "report.json"), "--html"], out: StringIO.new)
      assert_includes result["text"], "Dialog"
      assert_equal File.join(dir, "report.html"), result["html"]
    end
  end

  def test_cli_comment_without_post_only_returns_body
    result = ShadcnAudit::CLI::COMMANDS["comment"].call([FIXTURE], out: StringIO.new)
    assert_equal false, result["posted"]
    assert result["body"].start_with?("<!-- shadcn-audit -->")
  end

  def test_cli_comment_refused_reports_not_posted
    shell = ShadcnAudit::FakeShell.new
      .stub(->(a) { a[0, 3] == %w[gh pr view] }, JSON.generate("headRefOid" => "f" * 40, "state" => "OPEN"))
    result = ShadcnAudit::CLI.comment([FIXTURE, "--post"], out: StringIO.new, shell: shell)
    assert_equal "refused", result["action"]
    assert_includes result["reason"], "head moved"
    assert_equal false, result["posted"]
    refute shell.argvs.any? { |a| a.include?("-F") }
  end
end
