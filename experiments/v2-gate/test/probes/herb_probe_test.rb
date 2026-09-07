require "test_helper"

# Phase 0 probes (plan §4). Every expectation is one fixed canonical string, so
# "identical on both lanes" is checked by running this file under Gemfile.herb
# and under Gemfile.erubi. Results are summarized in HERB_FINDINGS.md.
class HerbProbeTest < ActiveSupport::TestCase
  test "(i) tag.attributes(component.attrs) in attribute position: empty string, boolean, style, escaping" do
    assert_equal <<~HTML, Gate.canonical("probe/attr_probe")
      <div class="a b" data-flag="" data-x="" disabled style="width: max-content; top: 0;" title="q&quot;&lt;&gt;&amp;'"></div>
    HTML
  end

  test "(ii) render X.new do |g| — capture(self, &block) hands the component to the block" do
    assert_equal <<~HTML, Gate.canonical("probe/block_with_context")
      <div id="outer">
        <span>
          Probes::Div:outer
        </span>
      </div>
    HTML
  end

  test "(iii) a nested render inside that block" do
    assert_equal <<~HTML, Gate.canonical("probe/nested_render")
      <div id="outer">
        <div data-parent="outer" id="inner">
          <em>
            deep
          </em>
        </div>
      </div>
    HTML
  end

  test "(iv) control — helper with block, render partial &block, <%= yield %> (ReActionView #57)" do
    actual = Gate.canonical("probe/issue57")
    record("issue57", actual)

    assert_equal <<~HTML, actual
      <section class="issue57">
        <div class="wrapper">
          <em>
            static
          </em>
          caller
        </div>
      </section>
    HTML
  end

  test "(b) <div><span></div> raises Herb::Engine::CompilationError under Herb and compiles on erubi" do
    if Gate.compiles_with_herb?
      error = assert_raises(ActionView::Template::Error) { Gate.render("probe/bad_nesting") }
      assert_kind_of Herb::Engine::CompilationError, error.cause
      record("bad_nesting", error.cause.message)
    else
      assert_equal "<div><span></div>", Gate.render("probe/bad_nesting")
    end
  end

  private

  # Evidence for HERB_FINDINGS.md: tmp/probes/<lane>/<name>.txt
  def record(name, text)
    dir = Rails.root.join("tmp/probes", Gate.lane)
    FileUtils.mkdir_p(dir)
    File.write(dir.join("#{name}.txt"), text)
  end
end
