require "test_helper"

# Parity: each scenario view, rendered through the gate controller and reduced
# to the gem's canonical form, must be byte-identical to the 1.6 snapshot.
# Run once per lane:
#
#   BUNDLE_GEMFILE=Gemfile.herb  bin/rails test test/golden
#   BUNDLE_GEMFILE=Gemfile.erubi bin/rails test test/golden
class GoldenParityTest < ActiveSupport::TestCase
  Gate::Scenarios.all.each do |scenario|
    test "#{scenario.slug} matches the 1.6 snapshot on the #{Gate.lane} lane" do
      assert_parity scenario, scenario.template
    end

    # Spike lane: the same scenario written with Herb component tags
    # (app/views/gate/<slug>_tags.html.erb) must reach the same snapshot.
    if Gate.tags? && Rails.root.join("app/views/gate/#{scenario.component}_#{scenario.name}_tags.html.erb").exist?
      test "#{scenario.slug} matches the 1.6 snapshot written with component tags" do
        assert_parity scenario, "#{scenario.template}_tags"
      end
    end
  end

  private

  def assert_parity(scenario, template)
    canonical = Gate.canonical(template)

    assert_equal canonical, Gate.canonical(template),
      "#{template} does not render deterministically"

    recorded = File.read(scenario.snapshot_path)

    assert_equal recorded, Golden::CanonicalHtml.call(recorded),
      "the recorded snapshot #{scenario.snapshot} is not a fixed point of the normalizer"

    assert_equal recorded, canonical,
      "HTML for #{template} (#{Gate.lane} lane) differs from gem/test/golden/snapshots/#{scenario.snapshot}.html"
  end
end
