# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "golden/canonical_html"
require "golden/harness"
require "golden/catalog"
require "golden/scenarios"

# The golden suite: the operational definition of "parity with 1.6".
#
#   bundle exec rake golden           # verify
#   bundle exec rake golden:update    # re-record the snapshots
#
# Every scenario in test/golden/scenarios.rb is rendered, reduced to the
# canonical form defined in test/golden/canonical_html.rb, and compared against
# a committed snapshot under test/golden/snapshots/. A failure here is either a
# deliberate change to the markup — in which case re-record and review the diff
# — or a regression.
class GoldenSuiteTest < Minitest::Test
  UPDATE = ENV["UPDATE_GOLDEN_SNAPSHOTS"] == "1"

  Golden::Catalog.scenarios.each do |scenario|
    define_method(scenario.test_name) { assert_golden(scenario) }
  end

  private

  def assert_golden(scenario)
    canonical = canonicalize(scenario)

    # Rendering twice catches any source of non-determinism the harness has not
    # pinned, wherever it lives, before it can be baked into a snapshot.
    assert_equal canonical, canonicalize(scenario),
      "#{scenario.slug} does not render deterministically; pin the new source in test/golden/harness.rb"

    # A pending scenario has been rendered — it must not raise, and must be
    # stable within one Ruby — but its markup is not pinned. See the reason.
    skip "#{scenario.slug} is not pinned: #{scenario.pending}" unless scenario.pinned?

    if UPDATE
      FileUtils.mkdir_p(File.dirname(scenario.snapshot_path))
      File.write(scenario.snapshot_path, canonical)
    end

    assert_path_exists scenario.snapshot_path,
      "no snapshot for #{scenario.slug} — run `bundle exec rake golden:update` and review the diff"

    recorded = File.read(scenario.snapshot_path)

    # The comparison is a byte comparison of canonical forms, and it is only a
    # structural comparison because the canonical form is a fixed point of the
    # normalizer: re-parsing a snapshot yields the snapshot. Asserting that here
    # keeps the normalizer honest — if it ever stopped being idempotent, every
    # snapshot would silently become a string test again.
    assert_equal recorded, Golden::CanonicalHtml.call(recorded),
      "the recorded canonical form of #{scenario.slug} is not a fixed point of the normalizer"

    assert_equal recorded, canonical,
      "HTML for #{scenario.slug} no longer matches the recorded 1.6 snapshot"
  end

  def canonicalize(scenario)
    Golden::CanonicalHtml.call(Golden::Harness.render(&scenario.block))
  end
end

# The suite is only a ruler if it measures the whole catalog. These three tests
# are what stop it from quietly shrinking.
class GoldenCoverageTest < Minitest::Test
  def test_every_component_directory_has_at_least_one_scenario
    covered = Golden::Catalog.scenarios.map(&:component).uniq
    missing = Golden::Catalog.component_directories - covered

    assert_empty missing,
      "component directories with no golden scenario: #{missing.join(", ")}"
  end

  def test_every_component_class_is_rendered_by_a_scenario
    missing = Golden::Catalog.component_classes - self.class.rendered_classes

    assert_empty missing,
      "RubyUI::Base subclasses no golden scenario renders: #{missing.join(", ")}"
  end

  def test_no_orphan_snapshot_files
    expected = Golden::Catalog.scenarios.select(&:pinned?).map(&:snapshot_path).sort
    on_disk = Dir.glob(File.join(Golden::Catalog::SNAPSHOT_ROOT, "**", "*.html")).sort
    orphans = on_disk - expected

    assert_empty orphans,
      "snapshot files with no scenario (delete them): #{orphans.map { |path| path.delete_prefix("#{Golden::Catalog::SNAPSHOT_ROOT}/") }.join(", ")}"
  end

  # Rendering the whole catalog once, memoized, because Minitest runs tests in
  # a random order and the coverage check cannot rely on the scenario tests
  # having run first.
  def self.rendered_classes
    @rendered_classes ||= begin
      Golden::Catalog.scenarios.each { |scenario| Golden::Harness.render(&scenario.block) }
      Golden::Harness.classes_rendered.keys.sort
    end
  end
end
