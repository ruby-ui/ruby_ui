require "test_helper"

class RegistryTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
  end

  def test_version
    assert_equal "1.2.0", @registry.version
  end

  def test_list_returns_all_components
    names = @registry.list.map { |c| c[:name] }
    assert_equal %w[Button Dialog], names.sort
  end

  def test_find_by_name_case_insensitive
    assert_equal "Button", @registry.find("button")[:name]
    assert_equal "Button", @registry.find("Button")[:name]
  end

  def test_find_unknown_returns_nil
    assert_nil @registry.find("Nonexistent")
  end

  def test_search_matches_name
    results = @registry.search("dial")
    assert_equal ["Dialog"], results.map { |r| r[:name] }
  end

  def test_search_matches_description
    results = @registry.search("modal")
    assert_equal ["Dialog"], results.map { |r| r[:name] }
  end

  def test_validate_names_returns_known_and_unknown
    known, unknown = @registry.partition_names(["Button", "Bogus"])
    assert_equal ["Button"], known
    assert_equal ["Bogus"], unknown
  end
end
