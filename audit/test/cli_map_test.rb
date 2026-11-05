require "test_helper"

class CliMapTest < Minitest::Test
  def run_cli(*argv)
    out = StringIO.new
    ShadcnAudit::CLI.start(argv, out: out)
    JSON.parse(out.string)
  end

  def test_map_prints_entry
    assert_equal "dialog", run_cli("map", "dialog")["shadcn"]
  end

  # clipboard has no shadcn counterpart, so it stays unmapped.
  def test_map_unmapped_prints_suggestion
    result = run_cli("map", "clipboard")
    assert_equal true, result["missing"]
    assert_equal "audit/component_map/clipboard.yml", result["path"]
    assert_equal "clipboard", YAML.safe_load(result["suggestion"])["shadcn"]
  end

  def test_divergences_lists_for_folder
    result = run_cli("divergences", "dialog")
    assert_equal "HTML", result["divergences"].first["dimension"]
    assert_empty run_cli("divergences", "not_a_component")["divergences"]
  end
end
