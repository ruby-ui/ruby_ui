require "test_helper"

class CliCollectTest < Minitest::Test
  def run_cli(argv, **opts)
    out = StringIO.new
    status = ShadcnAudit::CLI.run(argv, out: out, **opts)
    [status, JSON.parse(out.string)]
  end

  def test_usage_without_run
    status, result = run_cli(%w[collect dialog])
    assert_equal 1, status
    assert_match(/usage: collect <folder> --run <dir>/, result["error"])
  end

  def test_missing_browser_is_one_error_object
    factory = ->(audit_dir:, &block) { raise ShadcnAudit::Collect::BrowserError, "playwright not found: run `pnpm install && pnpm exec playwright install chromium` in audit/" }
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "audit"))
      File.write(File.join(dir, "audit/component_map.yml"),
        "dialog:\n  kind: modal\n  parts: {DialogContent: dialog-content}\n  selectors: {DialogContent: div}\n")
      status, result = run_cli(["collect", "dialog", "--run", File.join(dir, "run")], driver_factory: factory, root: Pathname.new(dir))
      assert_equal 1, status
      assert_includes result["error"], "pnpm exec playwright install chromium"
    end
  end
end
