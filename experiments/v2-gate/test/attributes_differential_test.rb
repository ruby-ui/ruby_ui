require "test_helper"
require "phlex"

# RubyUI::Attributes against Phlex 2.4.1, the serializer the 1.6 snapshots were
# recorded with. Each hash is rendered by Phlex::HTML#div(**h) and by
# <div <%= tag.attributes(RubyUI::Attributes.flat(h)) %>>, both canonicalized.
class AttributesDifferentialTest < ActiveSupport::TestCase
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
    "empty token list omits the attribute" => {class: [], data: {tokens: [nil]}}
  }.freeze

  FLAT_CASES.each do |label, attributes|
    test "flat: #{label}" do
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
    test "mix ##{index + 1}: #{defaults.inspect} + #{user.inspect}" do
      oracle = PhlexDiv.new({}).send(:mix, defaults, user)
      mixed = RubyUI::Attributes.mix(defaults, user)

      assert_equal oracle, mixed
      assert_equal canonical_phlex(oracle), canonical_erb(mixed)
    end
  end

  test "merge_classes accepts the array mix produces and applies tailwind_merge like 1.6 Base" do
    assert_equal "p-2 px-4", RubyUI::Attributes.merge_classes(["p-2", nil, ["px-4"]])
    assert_equal "py-2 px-8", RubyUI::Attributes.merge_classes("px-4 py-2 px-8")
  end

  private

  def canonical_phlex(attributes)
    Golden::CanonicalHtml.call(PhlexDiv.new(attributes).call)
  end

  def canonical_erb(attributes)
    Gate.canonical("probe/attributes", locals: {h: attributes})
  end
end
