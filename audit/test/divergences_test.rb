require "test_helper"

class DivergencesTest < Minitest::Test
  def setup
    @tmp = Dir.mktmpdir
    @path = File.join(@tmp, "divergences.yml")
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def write(yaml)
    File.write(@path, yaml)
    ShadcnAudit::Divergences.load(@path)
  end

  def valid_yaml
    <<~YAML
      - component: dialog
        dimension: HTML
        rubyui: "<dialog> + showModal()"
        shadcn: "<div role=\\"dialog\\">"
        reason: "Native modal dialog."
        since: "2026-10-26"
    YAML
  end

  def test_find_hit_and_miss
    divergences = write(valid_yaml)

    assert_equal "Native modal dialog.", divergences.find(component: "dialog", dimension: "HTML")["reason"]
    assert_nil divergences.find(component: "dialog", dimension: "Look")
    assert_nil divergences.find(component: "sheet", dimension: "HTML")
  end

  def test_for_component
    assert_equal 1, write(valid_yaml).for_component("dialog").size
    assert_empty write(valid_yaml).for_component("sheet")
  end

  def test_divergence_without_reason_raises
    error = assert_raises(ShadcnAudit::ConfigError) do
      write("- component: dialog\n  dimension: HTML\n  rubyui: a\n  shadcn: b\n")
    end
    assert_includes error.message, "dialog"
    assert_includes error.message, "reason"
  end

  def test_unknown_dimension_raises
    error = assert_raises(ShadcnAudit::ConfigError) do
      write("- component: dialog\n  dimension: Sound\n  reason: x\n")
    end
    assert_includes error.message, "Sound"
  end

  def test_suggest_yields_pasteable_yaml
    yaml = write(valid_yaml).suggest(component: "sheet", dimension: "Props", rubyui: "side: :left", shadcn: "side=\"left\"")
    entry = YAML.safe_load(yaml).first

    assert_equal "sheet", entry["component"]
    assert_equal "Props", entry["dimension"]
    assert_equal "side: :left", entry["rubyui"]
    assert_equal "side=\"left\"", entry["shadcn"]
    assert_equal "TODO", entry["reason"]
  end

  def test_missing_file_is_empty
    assert_nil ShadcnAudit::Divergences.load(File.join(@tmp, "none.yml")).find(component: "a", dimension: "HTML")
  end

  def test_seed_file_loads
    divergences = ShadcnAudit::Divergences.load(ShadcnAudit.root.join("audit/divergences.yml"))
    assert divergences.find(component: "dialog", dimension: "HTML")
  end

  def test_required_fields_must_be_non_empty
    %w[component rubyui shadcn reason].each do |key|
      yaml = valid_yaml.sub(/^(  |- )#{key}: .*$/) { "#{$1}#{key}: \"\"" }
      error = assert_raises(ShadcnAudit::ConfigError, key) { write(yaml) }
      assert_includes error.message, "missing #{key}"
    end
  end

  def test_top_level_must_be_a_list
    assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Divergences.new("oops") }
    assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Divergences.new({"component" => "dialog"}) }
  end

  def test_todo_reason_rejected
    error = assert_raises(ShadcnAudit::ConfigError) { write(valid_yaml.sub('reason: "Native modal dialog."', "reason: TODO")) }
    assert_includes error.message, "TODO"
  end

  def match_entry(match)
    [{"component" => "dialog", "dimension" => "Look", "rubyui" => "border 1px", "shadcn" => "ring 1px",
      "reason" => "Kept the border.", "since" => "2026-11-01", "match" => match}]
  end

  def look_match = {"part" => "DialogContent", "property" => "border-top-width", "rubyui" => "1px", "shadcn" => "0px"}

  def lookup(divergences, rubyui: "1px")
    divergences.match(component: "dialog", dimension: "Look", part: "DialogContent",
      key: "border-top-width", rubyui: rubyui, shadcn: "0px")
  end

  def test_match_finds_structured_entry
    divergences = ShadcnAudit::Divergences.new(match_entry(look_match))
    assert_equal "Kept the border.", lookup(divergences)["reason"]
  end

  def test_match_ignores_prose_only_entries
    entries = match_entry(look_match).map { |e| e.except("match") }
    assert_nil lookup(ShadcnAudit::Divergences.new(entries))
  end

  def test_match_requires_exact_values
    assert_nil lookup(ShadcnAudit::Divergences.new(match_entry(look_match)), rubyui: "2px")
  end

  def test_match_only_for_look_or_aria
    entries = match_entry(look_match).map { |e| e.merge("dimension" => "HTML") }
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Divergences.new(entries) }
    assert_match(/match is only for Look or ARIA/, error.message)
  end

  def test_look_match_needs_property
    match = look_match.except("property").merge("attribute" => "aria-expanded")
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Divergences.new(match_entry(match)) }
    assert_match(/Look match needs property/, error.message)
  end

  def test_match_needs_all_keys
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::Divergences.new(match_entry(look_match.except("rubyui"))) }
    assert_match(/match needs part, property\|attribute, rubyui and shadcn/, error.message)
  end

  def test_existing_registry_still_loads
    ShadcnAudit::Divergences.load(ShadcnAudit.root.join("audit/divergences.yml"))
  end
end
