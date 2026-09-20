require "test_helper"
require "golden/canonical_html"

# RubyUI::Attributes against Phlex 2.4.1, the serializer the 1.6 snapshots were
# recorded with. Each hash is rendered by Phlex::HTML#div(**h) and by
# <div <%= tag.attributes(RubyUI::Attributes.flat(h)) %>>, both canonicalized.
class AttributesDifferentialTest < Minitest::Test
  class PhlexDiv < Phlex::HTML
    def initialize(attributes)
      @attributes = attributes
    end

    def view_template
      div(**@attributes)
    end
  end

  FLAT_CASES = {
    "underscored keys at several levels" => {data_ruby_ui__dialog_target: "dialog", data: {ruby_ui__open_value: {deep_key: "v"}}},
    "nil and false omit the attribute" => {hidden: nil, disabled: false, data: {a: nil, b: false, c: "c"}},
    "true is a bare attribute" => {disabled: true, open: true, aria: {expanded: true}, data: {open: true}},
    "integers and floats" => {tabindex: 0, colspan: 2, data: {count: 3, ratio: 1.5}},
    "symbol values dasherize" => {dir: :ltr, data: {state: :on_hover}},
    "style hash" => {style: {width: "max-content", top: 0, left: 0}},
    "style array" => {style: ["width: 1px", "top: 0;", nil, {left: 0}]},
    "class array with nil and nesting" => {class: ["a", nil, ["b", ["c"]], "d"]},
    "nested data hash" => {data: {controller: "ruby-ui--dialog", action: "click->ruby-ui--dialog#open", ruby_ui__dialog_open_value: false}},
    "escaping" => {title: "q\"<>&'", data: {x: "<script>alert(1)</script>"}},
    "empty string is kept" => {value: "", data: {x: ""}},
    "string keys pass through" => {"data-x" => "1", "aria-label" => "L"},
    "root key from mix" => {data: {_: "root", x: "1"}},
    "date" => {datetime: Date.new(2026, 9, 7)},
    "empty token list omits the attribute" => {class: [], data: {tokens: [nil]}},
    "url attribute from a non-string" => {href: 1, src: ["/", "a.png"]},
    "javascript url is dropped, a data attribute is not" => {:href => :"javascript:x", "data-href" => "javascript:kept"},
    "out-of-range character reference" => {href: "java&#999999999999999999;script:alert(1)"},
    "a String \"style\" key nests instead of matching Phlex's Symbol :style" => {"style" => {width: "1px"}}
  }.freeze

  # Shapes where Phlex 2.4.1 raises inside `generate_nested_tokens` or
  # `generate_styles` — no `case` branch there for `true`/`false` or for
  # Date/Time — so `RubyUI::Attributes.flat` must raise too rather than
  # silently serialize something Phlex would refuse.
  RAISE_CASES = {
    "true has no case in a token list" => {class: [true]},
    "true has no case as a style value" => {style: {display: true}},
    "a Date has no case in nested attributes" => {data: {at: Date.today}}
  }.freeze

  RAISE_CASES.each do |label, attributes|
    define_method(:"test_raises_#{label.tr(" ", "_")}") do
      assert_raises(Phlex::ArgumentError) { PhlexDiv.new(attributes).call }
      assert_raises(ArgumentError) { RubyUI::Attributes.flat(attributes) }
    end
  end

  FLAT_CASES.each do |label, attributes|
    define_method(:"test_flat_#{label.tr(" ", "_")}") do
      assert_equal canonical_phlex(attributes), canonical_erb(attributes),
        "Phlex 2.4.1 and RubyUI::Attributes.flat disagree for #{attributes.inspect}"
    end
  end

  MIX_CASES = [
    [{class: "a"}, {class: "b"}],
    [{class: ["a", "b"]}, {class: "c"}],
    [{data: {a: 1, nested: {x: 1}}}, {data: {b: 2, nested: {y: 2}}}],
    [{class: "a", data: {x: 1}}, {class: nil, data: nil}],
    [{class: "a", data: {x: 1}}, {class!: "b", data!: {y: 2}}],
    [{data: {action: "click->a#b"}}, {data: {action: "click->c#d"}}],
    [{data: "x"}, {data: {y: 1}}],
    [{aria: {label: "l"}}, {aria: "flat"}]
  ].freeze

  MIX_CASES.each_with_index do |(defaults, user), index|
    define_method(:"test_mix_#{index + 1}") do
      oracle = PhlexDiv.new({}).send(:mix, defaults, user)
      mixed = RubyUI::Attributes.mix(defaults, user)

      assert_equal oracle, mixed
      assert_equal canonical_phlex(oracle), canonical_erb(mixed)
    end
  end

  def test_merge_classes_applies_tailwind_merge_like_1_6_base
    assert_equal "p-2 px-4", RubyUI::Attributes.merge_classes(["p-2", nil, ["px-4"]])
    assert_equal "py-2 px-8", RubyUI::Attributes.merge_classes("px-4 py-2 px-8")
  end

  private

  def canonical_phlex(attributes)
    Golden::CanonicalHtml.call(PhlexDiv.new(attributes).call)
  end

  def canonical_erb(attributes)
    Golden::CanonicalHtml.call(RubyUI::TestApp.view.render(template: "probe/attributes", locals: {h: attributes}))
  end
end
