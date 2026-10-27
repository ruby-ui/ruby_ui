require "test_helper"

class ReportTest < Minitest::Test
  FIXTURE = File.expand_path("fixtures/report_572.json", __dir__)

  def data = JSON.parse(File.read(FIXTURE))

  def dialog_lines(d) = d["components"].first["lines"]

  def test_valid_report_loads
    report = ShadcnAudit::Report.load(FIXTURE)
    assert_equal %w[dialog alert_dialog], report.components.map { |c| c["folder"] }
    assert_equal 572, report.header["pr"]
    assert_equal "8f04138777c1b6996e709993362a7b0a12888ecf", report.header["shadcn_sha"]
  end

  def test_basis_on_fail_rejected
    d = data
    dialog_lines(d)[1]["basis"] = "intentional"
    assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
  end

  def test_spec_finding_without_url_rejected
    d = data
    dialog_lines(d)[1].merge!("dimension" => "Spec", "source" => "style-vega.css:468")
    error = assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
    assert_match(/http/, error.message)
  end

  def test_pass_without_source_rejected
    d = data
    dialog_lines(d)[0]["source"] = ""
    assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
  end

  def test_unknown_status_dimension_and_basis_rejected
    {"status" => "great", "dimension" => "Vibes", "basis" => "because"}.each do |key, value|
      d = data
      dialog_lines(d)[0][key] = value
      assert_raises(ShadcnAudit::ReportError, key) { ShadcnAudit::Report.new(d) }
    end
  end

  def test_invalid_json_and_missing_keys_rejected
    Dir.mktmpdir do |dir|
      path = File.join(dir, "r.json")
      File.write(path, "{nope")
      assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.load(path) }
    end
    assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new({"target" => {}}) }
  end

  def test_fail_and_warn_without_source_rejected_inconclusive_allowed
    %w[fail warn].each do |status|
      d = data
      dialog_lines(d)[1].merge!("status" => status, "source" => " ")
      error = assert_raises(ShadcnAudit::ReportError, status) { ShadcnAudit::Report.new(d) }
      assert_includes error.message, "#{status} line needs a source"
    end
    d = data
    dialog_lines(d)[1].merge!("status" => "inconclusive", "source" => "")
    ShadcnAudit::Report.new(d)
  end

  def test_spec_basis_pass_needs_http_source
    d = data
    dialog_lines(d)[0].merge!("basis" => "spec", "source" => "style-vega.css:464")
    error = assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
    assert_includes error.message, "basis spec needs an http source"

    dialog_lines(d)[0]["source"] = "https://www.w3.org/TR/wai-aria-1.2/#dialog"
    ShadcnAudit::Report.new(d)
  end

  def test_sandbox_lock_required_as_object
    d = data
    d.delete("sandbox_lock")
    assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
    d["sandbox_lock"] = ["react@19"]
    error = assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
    assert_includes error.message, "sandbox_lock"
  end

  def test_target_needs_repo_and_both_shas
    %w[repo base_sha head_sha].each do |key|
      [nil, "", 1].each do |value|
        d = data
        d["target"][key] = value
        error = assert_raises(ShadcnAudit::ReportError, "#{key}=#{value.inspect}") { ShadcnAudit::Report.new(d) }
        assert_includes error.message, key
      end
    end
  end

  def test_theme_diff_entries_must_be_objects
    d = data
    d["theme"]["diffs"] << "chart-1 differs"
    error = assert_raises(ShadcnAudit::ReportError) { ShadcnAudit::Report.new(d) }
    assert_includes error.message, "theme diffs"
  end

  def test_component_folder_must_be_non_empty_string
    [nil, "", "  ", 42].each do |folder|
      d = data
      d["components"].first["folder"] = folder
      error = assert_raises(ShadcnAudit::ReportError, folder.inspect) { ShadcnAudit::Report.new(d) }
      assert_includes error.message, "folder"
    end
  end
end
