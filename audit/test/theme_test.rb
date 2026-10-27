require "test_helper"

class ThemeTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures", __dir__)
  THEMES_TS = File.join(FIXTURES, "registry/themes.ts")
  CSS = File.join(FIXTURES, "application.tailwind.css")

  def compare(css_path = CSS)
    ShadcnAudit::Theme.compare(themes_ts: THEMES_TS, rubyui_css: css_path)
  end

  def with_css(edit)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "app.css")
      original = File.read(CSS)
      edited = edit.call(original)
      raise "with_css: the edit left the CSS unchanged" if edited == original
      File.write(path, edited)
      yield path
    end
  end

  def test_identical_tokens_pass
    assert_equal({"status" => "pass", "diffs" => []}, compare)
  end

  def test_changed_dark_token_is_reported
    with_css(->(css) { css.sub(/(\.dark \{.*?--popover: )[^;]+;/m, '\1oklch(0.3 0 0);') }) do |path|
      result = compare(path)
      assert_equal "fail", result["status"]
      assert_equal [{"mode" => "dark", "token" => "popover", "rubyui" => "oklch(0.3 0 0)", "shadcn" => "oklch(0.205 0 0)"}], result["diffs"]
    end
  end

  def test_missing_token_is_reported
    with_css(->(css) { css.gsub(/^  --ring: [^;]+;\n/, "") }) do |path|
      diffs = compare(path)["diffs"]
      assert_includes diffs, {"mode" => "light", "token" => "ring", "rubyui" => nil, "shadcn" => "oklch(0.708 0 0)"}
      assert_includes diffs, {"mode" => "dark", "token" => "ring", "rubyui" => nil, "shadcn" => "oklch(0.556 0 0)"}
    end
  end

  def test_whitespace_and_comments_are_ignored
    with_css(->(css) { css.sub("--radius: 0.625rem;", "/* x */ --radius:\n    0.625rem ;") }) do |path|
      assert_equal "pass", compare(path)["status"]
    end
  end

  def test_rubyui_only_tokens_are_ignored
    with_css(->(css) { css.sub("--warning: hsl(38 92% 50%);", "--warning: red;") }) do |path|
      assert_equal "pass", compare(path)["status"]
    end
  end

  def test_unknown_theme_raises
    assert_raises(ArgumentError) { ShadcnAudit::Theme.compare(themes_ts: THEMES_TS, rubyui_css: CSS, name: "nope") }
  end

  def test_missing_or_empty_mode_block_raises
    ts = File.read(THEMES_TS)
    {
      "dark" => ts.sub(/\bdark:\s*\{/, "night: {"),
      "light" => ts.sub(/(\blight:\s*\{)[^}]*\}/m, '\1}')
    }.each do |mode, source|
      Dir.mktmpdir do |dir|
        path = File.join(dir, "themes.ts")
        File.write(path, source)
        error = assert_raises(ArgumentError) { ShadcnAudit::Theme.compare(themes_ts: path, rubyui_css: CSS) }
        assert_includes error.message, mode
      end
    end
  end

  def test_theme_without_css_vars_raises_argument_error
    Dir.mktmpdir do |dir|
      path = File.join(dir, "themes.ts")
      File.write(path, %(export const THEMES = [{ name: "neutral", title: "Neutral" }]\n))
      error = assert_raises(ArgumentError) { ShadcnAudit::Theme.compare(themes_ts: path, rubyui_css: CSS) }
      assert_equal %(cssVars not found for "neutral"), error.message
    end
  end
end
