# frozen_string_literal: true

require "test_helper"
require "golden/canonical_html"

# The 2.0 component layer, through the probe components under test/probes.
# Output is compared in canonical form where whitespace is irrelevant and raw
# where it is the point. Inherits the helper base for render_erb.
class LayerTest < ComponentTest
  def canonical(html)
    Golden::CanonicalHtml.call(html)
  end

  def view
    RubyUI::TestApp.view
  end

  def test_attrs_are_computed_with_no_view_context
    assert_equal({"class" => "probe", "data-probe" => ""}, RubyUI::Probes::Div.new.attrs)
  end

  def test_caller_classes_merge_over_defaults_and_nil_keeps_the_default
    assert_equal "probe p-4", RubyUI::Probes::Div.new(class: "p-4").attrs["class"]
    assert_equal "probe", RubyUI::Probes::Div.new(class: nil).attrs["class"]
    assert_equal "p-4", RubyUI::Probes::Div.new(class!: "p-4").attrs["class"]
  end

  def test_renders_the_sidecar_with_attributes_and_content
    assert_equal canonical(%(<div class="probe" data-probe="">Hello</div>)), canonical(render_erb("probe/div_default"))
  end

  def test_content_is_nil_when_rendered_without_a_block_even_after_a_render_with_one
    component = RubyUI::Probes::Div.new
    view.render(component) { "first" }

    assert_equal canonical(%(<div class="probe" data-probe=""></div>)), canonical(view.render(component))
  end

  def test_the_block_receives_the_component
    assert_includes render_erb("probe/div_block_arg"), "id=outer"
  end

  def test_a_component_renders_inside_another_components_block
    html = render_erb("probe/div_nested")

    assert_includes html, %(id="inner")
    assert_includes html, "in outer"
  end

  def test_a_component_can_render_nothing
    assert_equal "", view.render(RubyUI::Probes::Rootless.new(shown: false)).strip
    assert_includes view.render(RubyUI::Probes::Rootless.new), "shown"
  end

  def test_a_minted_id_and_its_reference_line_up
    html = view.render(RubyUI::Probes::WithId.new) { "body" }
    id = html[/id="(content[0-9a-f]{8})"/, 1]

    refute_nil id
    assert_includes html, %(aria-controls="#{id}")
  end

  def test_a_custom_element_root
    assert_equal canonical(%(<turbo-frame id="frame">x</turbo-frame>)), canonical(view.render(RubyUI::Probes::Frame.new) { "x" })
  end

  def test_content_presence_falls_back_to_the_placeholder
    assert_equal canonical("<span>Pick one</span>"), canonical(render_erb("probe/fallback_empty"))
    assert_equal canonical("<span>Pick one</span>"), canonical(render_erb("probe/fallback_blank"))
    assert_equal canonical("<span>Apple</span>"), canonical(render_erb("probe/fallback_text"))
  end

  def test_helpers_raises_outside_render_in
    error = assert_raises(ArgumentError) { RubyUI::Probes::Div.new.helpers }

    assert_match(/no view context/, error.message)
  end

  def test_a_missing_sidecar_is_named
    error = assert_raises(ArgumentError) { view.render(RubyUI::Probes::Bare.new) }

    assert_match(%r{ruby_ui/probes/bare\.html\.erb}, error.message)
  end

  def test_a_host_template_at_the_same_virtual_path_is_not_picked
    refute_includes render_erb("probe/div_default"), "HOST SHADOW"
  end

  def test_overlapping_roots_resolve_the_same_sidecar
    # With the gem directory itself as a root ahead of test/probes, Div's file
    # matches the wider root first; the relative path grows, the sidecar found
    # is the same one.
    original = RubyUI.component_roots
    RubyUI.component_roots = [RubyUI::TestApp::ROOT, *original]
    RubyUI::Probes::Div.remove_instance_variable(:@component_root) if RubyUI::Probes::Div.instance_variable_defined?(:@component_root)

    assert_equal canonical(%(<div class="probe" data-probe="">Hello</div>)), canonical(render_erb("probe/div_default"))
  ensure
    RubyUI.component_roots = original
    RubyUI::Probes::Div.remove_instance_variable(:@component_root) if RubyUI::Probes::Div.instance_variable_defined?(:@component_root)
  end

  def test_component_roots_are_registered_resolvers_the_reloader_can_see
    RubyUI::Probes::Div.template
    # Phase 2.0a has no real gem component under the `lib` root yet — every
    # component that exists is a probe under `test/probes` — so nothing but
    # this test ever resolves a sidecar there. Call `lookup_for` on every
    # configured root directly (the same call `Component.template` makes) so
    # the assertion below does not depend on some other root having already
    # been exercised by an unrelated test.
    RubyUI.component_roots.each { |root| RubyUI.lookup_for(root) }
    paths = ActionView::PathRegistry.all_file_system_resolvers.map(&:path)
    RubyUI.component_roots.each { |root| assert_includes paths, root.to_s }
  end

  class Homeless < RubyUI::Component
  end

  def test_a_class_outside_every_component_root_is_refused
    error = assert_raises(ArgumentError) { Homeless.template }

    assert_match(/component_roots/, error.message)
  end

  def test_mixed_attrs_is_the_nested_hash_with_classes_merged
    component = RubyUI::Probes::Div.new(class: "p-4", data: {x: 1})

    assert_equal({class: "probe p-4", data: {probe: true, x: 1}}, component.mixed_attrs)
    assert_equal({"class" => "probe p-4", "data-probe" => "", "data-x" => "1"}, component.attrs)
  end

  def test_mixed_attrs_is_frozen
    assert_predicate RubyUI::Probes::Div.new.mixed_attrs, :frozen?
  end

  def test_the_sidecars_final_newline_is_not_output
    sidecar = File.join(RubyUI::TestApp::ROOT, "test/probes/ruby_ui/probes/div.html.erb")
    assert File.read(sidecar).end_with?("\n"), "the probe's sidecar must end with a newline for this test to mean anything"

    assert_equal %(<div class="probe" data-probe="">x</div>), view.render(RubyUI::Probes::Div.new) { "x" }
  end

  def test_nested_components_emit_nothing_between_them
    v = view
    html = v.render(RubyUI::Probes::Div.new(id: "o")) { v.render(RubyUI::Probes::Div.new(id: "i")) { "x" } }

    assert_equal %(<div class="probe" data-probe="" id="o"><div class="probe" data-probe="" id="i">x</div></div>), html
  end

  # A host's `class MyButton < RubyUI::Button`: defined under no component root,
  # with no sidecar of its own.
  class HostSubclass < RubyUI::Probes::Div
  end

  def test_a_subclass_without_a_sidecar_renders_its_nearest_ancestors
    assert_equal %(<div class="probe" data-probe="">i</div>), view.render(RubyUI::Probes::Inherited.new) { "i" }
    assert_equal %(<div class="probe" data-probe="">h</div>), view.render(HostSubclass.new) { "h" }
  end

  def test_a_subclass_with_its_own_sidecar_uses_it
    assert_equal %(<p class="probe" data-probe="">o</p>), view.render(RubyUI::Probes::Overridden.new) { "o" }
  end

  # A host's app/components/my_button.rb: the class file directly under a
  # root, where File.split gives "." for the prefix.
  def test_a_class_directly_under_a_root_finds_its_sidecar
    assert_equal "<i>r</i>", view.render(RootProbe.new) { "r" }
  end

  def test_the_contents_own_trailing_newline_survives
    assert_equal %(<div class="probe" data-probe="">body\n</div>), view.render(RubyUI::Probes::Div.new) { "body\n" }
  end

  def test_erb_compiles_an_inline_template_through_herb
    assert_raises(ActionView::SyntaxErrorInTemplate) { erb("<div><span></div>") }
    assert_equal %(<div class="probe" data-probe="">Hello</div>), erb(%(<%= render RubyUI::Probes::Div.new do %>Hello<% end %>))
  end

  def test_the_sidecar_source_is_read_once_per_template_not_per_render
    # Warm the template: ActionView reads the source to compile it, and the
    # newline flag is read once more on the first render. After that, no read.
    view.render(RubyUI::Probes::Div.new) { "warm" }
    template = RubyUI::Probes::Div.template
    reads = 0
    source = template.source
    template.define_singleton_method(:source) do
      reads += 1
      source
    end

    3.times { view.render(RubyUI::Probes::Div.new) { "x" } }

    assert_equal 0, reads, "Template#source rereads the file; render_in must not call it on every render"
  end

  # A sidecar file without a final newline: nothing is dropped, so content
  # that itself ends in a newline keeps it.
  def test_a_sidecar_without_a_final_newline_drops_nothing
    sidecar = File.join(RubyUI::TestApp::ROOT, "test/probes/ruby_ui/probes/unterminated.html.erb")
    refute File.read(sidecar).end_with?("\n"), "the probe's sidecar must not end with a newline for this test to mean anything"

    assert_equal "<u>body\n</u>", view.render(RubyUI::Probes::Unterminated.new) { "body\n" }
  end
end
