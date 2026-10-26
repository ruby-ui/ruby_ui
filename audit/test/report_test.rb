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
end
