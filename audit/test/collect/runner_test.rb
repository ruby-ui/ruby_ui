require "test_helper"

class CollectRunnerTest < Minitest::Test
  Runner = ShadcnAudit::Collect::Runner

  # Canned driver: every observation reaches the state with one identical
  # element per selector, except the states listed in `unreached`.
  class FakeDriver
    attr_reader :observed

    def initialize(unreached: [])
      @unreached = unreached
      @observed = []
    end

    def environment(url) = {"w" => 1280, "h" => 800, "font" => url.include?("3179") ? "Inter" : "Geist"}

    def observe(url:, state:, selectors:, screenshot_path:)
      @observed << [url, state, selectors]
      return {"reached" => false, "reason" => "boom", "screenshot" => nil, "parts" => {}} if @unreached.include?(state)

      ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::WHITE).save(screenshot_path.to_s)
      parts = selectors.keys.to_h { |part| [part, [{"styles" => {"padding-top" => "8px"}, "aria" => "- button", "attrs" => {}}]] }
      {"reached" => true, "reason" => nil, "screenshot" => screenshot_path.to_s, "parts" => parts}
    end
  end

  def setup
    @tmp = Dir.mktmpdir
    @root = File.join(@tmp, "root")
    @run = File.join(@tmp, "run")
    write_map(@root, "kind: modal\n  parts: {Dialog: dialog, DialogContent: dialog-content, DialogMiddle: null}\n  selectors: {DialogContent: \"dialog > div\"}")
    @driver = FakeDriver.new
  end

  def teardown = FileUtils.remove_entry(@tmp)

  def write_map(root, body)
    FileUtils.mkdir_p(File.join(root, "audit"))
    File.write(File.join(root, "audit/component_map.yml"), "dialog:\n  shadcn: dialog\n  #{body}\n")
    File.write(File.join(root, "audit/divergences.yml"), "[]\n")
  end

  def run_collect(preview: nil, driver: @driver, **urls)
    factory = ->(audit_dir:, &block) { block.call(driver) }
    Runner.new(folder: "dialog", run_dir: @run, preview: preview, root: Pathname.new(@root),
      theme: {"diffs" => []}, driver_factory: factory, **urls).call
  end

  def test_url_templates_can_point_at_other_ports
    run_collect(shadcn_url: "http://localhost:5180/?c={folder}&theme={light|dark}",
      rubyui_url: "http://localhost:3180/__audit/{folder}?theme={light|dark}")
    urls = @driver.observed.map(&:first).uniq
    assert_includes urls, "http://localhost:5180/?c=dialog&theme=light"
    assert_includes urls, "http://localhost:3180/__audit/dialog?theme=dark"
  end

  def test_writes_collect_json_and_returns_same_object
    result = run_collect
    assert_equal JSON.parse(JSON.generate(result)), JSON.parse(File.read(File.join(@run, "collect.json")))
    assert_equal({"w" => 1280, "h" => 800}, result["viewport"])
    assert_includes result["screenshots"], {"state" => "open (light)", "rubyui" => "screens/dialog-open-rubyui-light.png", "shadcn" => "screens/dialog-open-shadcn-light.png"}
    assert_equal ["font: Inter vs Geist (light)", "font: Inter vs Geist (dark)"], result["environment_diffs"]
    assert(result["pixel_diffs"].key?("open/light"))
    shadcn_selectors = @driver.observed.find { |url, _, _| url.include?("5179") }[2]
    assert_equal({"DialogContent" => %([data-slot="dialog-content"])}, shadcn_selectors)
  end

  def test_states_follow_kind
    write_map(@root, "kind: form_control\n  parts: {DialogContent: dialog-content}\n  selectors: {DialogContent: \"div\"}")
    assert_equal %w[closed focus], run_collect["states"].map { |o| o["state"] }.uniq
  end

  def test_missing_selector_part_is_inconclusive
    line = run_collect["lines"].find { |l| l["note"].include?("no selector") }
    assert_equal ["Look", "inconclusive", "Dialog: no selector in component_map.yml"], line.values_at("dimension", "status", "note")
  end

  def test_null_selector_part_is_skipped_silently
    write_map(@root, "kind: modal\n  parts: {Dialog: dialog, DialogContent: dialog-content}\n  selectors: {Dialog: null, DialogContent: \"dialog > div\"}")
    result = run_collect
    refute(result["lines"].any? { |l| l["note"].include?("no selector") })
    refute(@driver.observed.any? { |_, _, selectors| selectors.key?("Dialog") })
  end

  def test_preview_map_wins_when_it_has_selectors
    preview = File.join(@tmp, "preview")
    write_map(preview, "kind: static\n  parts: {DialogContent: dialog-content}\n  selectors: {DialogContent: \"section\"}")
    result = run_collect(preview: preview)
    assert_equal "preview", result["map_source"]
    assert_equal %w[closed], result["states"].map { |o| o["state"] }.uniq
  end

  def test_falls_back_to_working_tree_map
    preview = File.join(@tmp, "preview")
    write_map(preview, "kind: static\n  parts: {DialogContent: dialog-content}")
    assert_equal "working tree", run_collect(preview: preview)["map_source"]
  end

  def test_folder_without_selectors_is_an_error
    write_map(@root, "kind: modal\n  parts: {DialogContent: dialog-content}")
    error = assert_raises(ArgumentError) { run_collect }
    assert_equal "dialog has no selectors in audit/component_map.yml", error.message
  end

  def test_unreadable_screenshot_only_fails_its_own_diff
    driver = FakeDriver.new
    def driver.observe(**kwargs)
      super.tap { |facts| File.write(kwargs[:screenshot_path], "not a png") if kwargs[:state] == "open" }
    end
    diffs = run_collect(driver: driver)["pixel_diffs"]
    assert diffs["open/light"].key?("error")
    assert_equal 0, diffs["closed/light"]["pixels"]
  end

  def test_driver_error_on_one_state_does_not_abort
    result = run_collect(driver: FakeDriver.new(unreached: %w[open]))
    assert File.exist?(File.join(@run, "collect.json"))
    notes = result["lines"].select { |l| l["status"] == "inconclusive" }.map { |l| l["note"] }
    assert_includes notes, "open/light, open/dark not reached on rubyui: boom"
  end

  def test_failed_environment_probe_is_recorded_not_raised
    driver = FakeDriver.new
    def driver.environment(url) = url.include?("3179") ? {"error" => "net::ERR_CONNECTION_REFUSED"} : super
    result = run_collect(driver: driver)
    assert_includes result["environment_diffs"], "environment probe failed on rubyui (light): net::ERR_CONNECTION_REFUSED"
    assert File.exist?(File.join(@run, "collect.json"))
  end
end
