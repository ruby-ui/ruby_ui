require "test_helper"

# Drives real headless Chromium against local HTML. Skips when Playwright or
# its browser isn't installed (CI runs only the browser-free tests).
class CollectDriverSmokeTest < Minitest::Test
  Driver = ShadcnAudit::Collect::Driver
  FIXTURES = File.expand_path("../fixtures/collect", __dir__)
  SELECTORS = {"Trigger" => "[data-audit-trigger]", "Panel" => ".part"}.freeze

  def setup
    @tmp = Dir.mktmpdir
  end

  def teardown = FileUtils.remove_entry(@tmp)

  def url(name) = "file://#{FIXTURES}/#{name}"

  def with_driver(&block)
    Driver.open(audit_dir: ShadcnAudit.root.join("audit"), &block)
  rescue ShadcnAudit::Collect::BrowserError => e
    skip "chromium not installed: #{e.message}"
  end

  def observe(driver, name, state)
    driver.observe(url: url(name), state: state, selectors: SELECTORS, screenshot_path: File.join(@tmp, "#{name}-#{state}.png"))
  end

  def test_states_against_local_fixtures
    with_driver do |driver|
      closed = observe(driver, "a.html", "closed")
      assert closed["reached"]
      assert_equal [], closed["parts"]["Panel"]

      open = observe(driver, "a.html", "open")
      assert open["reached"], open["reason"]
      assert_equal 1, open["parts"]["Panel"].size
      assert_equal "8px", open["parts"]["Panel"][0]["styles"]["padding-top"]
      trigger = open["parts"]["Trigger"][0]
      assert_equal({"aria-expanded" => "true", "aria-controls" => "resolves"}, trigger["attrs"].slice("aria-expanded", "aria-controls"))
      assert_includes trigger["aria"], "button"
      assert File.exist?(open["screenshot"])

      focus = observe(driver, "a.html", "focus")
      assert focus["reached"], focus["reason"]

      after = observe(driver, "a.html", "after-esc")
      assert after["reached"]
      assert_equal [], after["parts"]["Panel"]

      missing = observe(driver, "b.html", "open")
      refute missing["reached"]
      assert_equal "no [data-audit-trigger]", missing["reason"]

      broken = observe(driver, "nope.html", "closed")
      refute broken["reached"]
      refute_empty broken["reason"]

      env = driver.environment(url("a.html"))
      assert_equal [1280, 800, 1], env.values_at("w", "h", "dpr")
    end
  end

  def test_errors_visibility_modality_and_infinite_animations
    selectors = {"Dialog" => "dialog", "Ghost" => ".ghost", "Pulse" => ".pulse", "Slow" => ".slow"}
    with_driver do |driver|
      run = ->(name, state) { driver.observe(url: url(name), state: state, selectors: selectors, screenshot_path: File.join(@tmp, "#{name}-#{state}.png")) }

      thrown = run.call("c.html", "open")
      refute thrown["reached"]
      assert_includes thrown["reason"], "boom on click"

      open = run.call("d.html", "open")
      assert open["reached"], open["reason"]
      assert_equal "true", open["parts"]["Dialog"][0]["attrs"]["modal"]
      assert_equal [], open["parts"]["Ghost"]

      closed = 2.times.map { run.call("d.html", "closed")["parts"] }
      assert_equal ["1", "1"], closed.map { |parts| parts["Pulse"][0]["styles"]["opacity"] }
      # A finite animation longer than the settle cap ends at its final frame, not its first.
      assert_equal ["1", "1"], closed.map { |parts| parts["Slow"].dig(0, "styles", "opacity") }

      env = driver.environment(url("nope.html"))
      assert env["error"], env.inspect
    end
  end

  def test_waits_for_client_mounted_fixture_and_resolves_id_refs
    with_driver do |driver|
      open = driver.observe(url: url("e.html"), state: "open", selectors: {"Trigger" => "[data-audit-trigger]"},
        screenshot_path: File.join(@tmp, "e.png"))
      assert open["reached"], open["reason"]
      attrs = open["parts"]["Trigger"][0]["attrs"]
      assert_equal({"aria-controls" => "resolves", "aria-describedby" => "dangling"}, attrs.slice("aria-controls", "aria-describedby"))
    end
  end

  def test_mount_error_is_reported_instead_of_missing_fixture
    with_driver do |driver|
      facts = driver.observe(url: url("f.html"), state: "closed", selectors: {}, screenshot_path: File.join(@tmp, "f.png"))
      refute facts["reached"]
      assert_includes facts["reason"], "mount failed"
    end
  end
end
