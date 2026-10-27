require "test_helper"
require "open3"
require "rbconfig"

class CliErrorsTest < Minitest::Test
  EXE = ShadcnAudit.root.join("audit/exe/shadcn-audit").to_s

  def run_cli(*argv)
    out = StringIO.new
    status = ShadcnAudit::CLI.run(argv, out: out)
    [status, JSON.parse(out.string)]
  end

  def with_file(content)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "report.json")
      File.write(path, content)
      yield path
    end
  end

  def test_bad_report_json_is_one_error_object
    with_file("{not json") do |path|
      status, result = run_cli("render", path)
      assert_equal 1, status
      assert_match(/not valid JSON/, result["error"])
    end
  end

  def test_report_breaking_the_schema_is_one_error_object
    with_file("[]") do |path|
      status, result = run_cli("comment", path)
      assert_equal 1, status
      assert_match(/JSON object/, result["error"])
    end
  end

  def test_missing_file_is_one_error_object
    status, result = run_cli("render", "/nonexistent/report.json")
    assert_equal 1, status
    assert_match(/No such file/, result["error"])
  end

  def test_missing_argument_is_one_error_object
    status, result = run_cli("map")
    assert_equal 1, status
    assert_match(/usage: map/, result["error"])
  end

  def test_success_returns_zero
    status, result = run_cli("map", "dialog")
    assert_equal 0, status
    assert_equal "dialog", result["shadcn"]
  end

  def test_exe_prints_json_and_exits_1_on_bad_input
    with_file("{not json") do |path|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, EXE, "render", path)
      assert_equal 1, status.exitstatus
      assert_empty stderr
      assert_match(/not valid JSON/, JSON.parse(stdout)["error"])
    end
    stdout, _, status = Open3.capture3(RbConfig.ruby, EXE, "render", "/nonexistent/report.json")
    assert_equal 1, status.exitstatus
    assert JSON.parse(stdout).key?("error")
  end

  def test_malformed_yaml_is_one_error_object
    with_file("dialog:\n  shadcn: [unclosed\n") do |path|
      ShadcnAudit::CLI::COMMANDS["load_map"] = ->(args, out:) { ShadcnAudit::ComponentMap.load(args.first) }
      status, result = run_cli("load_map", path)
      assert_equal 1, status
      assert_includes result["error"], path
    ensure
      ShadcnAudit::CLI::COMMANDS.delete("load_map")
    end
  end
end
