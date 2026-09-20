# frozen_string_literal: true

require "test_helper"

# Phlex 2.4.1's attribute guards, ported into the 2.0 layer so a component
# given untrusted values keeps the protection it has today. Each case mirrors
# phlex/sgml/attributes.rb; the differential test covers the happy path.
class AttributesTest < Minitest::Test
  def flat(**attributes)
    RubyUI::Attributes.flat(attributes)
  end

  def test_an_event_handler_attribute_name_raises
    assert_raises(ArgumentError) { flat(onclick: "x") }
    assert_raises(ArgumentError) { flat("onClick" => "x") }
    assert_raises(ArgumentError) { flat(onerror: "x") }
  end

  def test_srcdoc_sandbox_and_http_equiv_raise
    assert_raises(ArgumentError) { flat(srcdoc: "<p>") }
    assert_raises(ArgumentError) { flat(sandbox: "") }
    assert_raises(ArgumentError) { flat("http-equiv" => "refresh") }
  end

  # Phlex checks the name before it looks at the value, so a Hash under an
  # unsafe name cannot smuggle it in through the `_` root key.
  def test_an_unsafe_name_is_refused_before_its_hash_value_is_read
    assert_raises(ArgumentError) { flat(onclick: {_: "x"}) }
    assert_raises(ArgumentError) { flat(srcdoc: {_: "<p>"}) }
  end

  def test_a_name_with_forbidden_characters_raises_at_any_level
    assert_raises(ArgumentError) { flat("bad name" => "1") }
    assert_raises(ArgumentError) { flat("a=b" => "1") }
    assert_raises(ArgumentError) { flat(data: {"x y" => "1"}) }
  end

  def test_a_javascript_url_is_dropped_from_a_url_attribute
    assert_equal({}, flat(href: "javascript:alert(1)"))
    assert_equal({}, flat(src: "JavaScript:alert(1)"))
    assert_equal({}, flat(href: " java\nscript:alert(1)"))
    assert_equal({}, flat(href: "&#106;avascript:alert(1)"))
    assert_equal({}, flat(href: "&#x6A;avascript:alert(1)"))
    assert_equal({}, flat(href: "javascript&colon;alert(1)"))
    assert_equal({}, flat(formaction: "javascript:alert(1)"))
  end

  def test_an_ordinary_url_is_kept
    assert_equal({"href" => "/edit"}, flat(href: "/edit"))
    assert_equal({"href" => "https://example.com/?q=javascript"}, flat(href: "https://example.com/?q=javascript"))
    assert_equal({"src" => "javascript-guide.png"}, flat(src: "javascript-guide.png"))
  end

  def test_a_non_string_value_is_serialized_then_checked
    # Phlex serializes first and checks the result: 1 and :edit are ordinary
    # values, a Symbol that spells a javascript: URL is not.
    assert_equal({"href" => "1"}, flat(href: 1))
    assert_equal({"href" => "edit"}, flat(href: :edit))
    assert_equal({"href" => "/ edit"}, flat(href: ["/", "edit"]))
    assert_equal({}, flat(href: :"javascript:x"))
  end

  def test_an_out_of_range_character_reference_decodes_to_nothing
    # Phlex rescues the failed pack and treats the reference as empty, which
    # leaves `javascript:` in front.
    assert_equal({}, flat(href: "java&#999999999999999999;script:alert(1)"))
  end

  def test_true_is_allowed_on_a_url_attribute
    assert_equal({"href" => ""}, flat(href: true))
  end

  def test_a_nested_on_key_is_not_an_event_handler
    # Phlex checks `on*` only on top-level names; `data-onclick` is a plain
    # data attribute and stays one here.
    assert_equal({"data-onclick" => "x"}, flat(data: {onclick: "x"}))
  end

  def test_the_guard_does_not_touch_ordinary_attributes
    assert_equal({"class" => "a b", "data-open" => "", "aria-label" => "L"},
      flat(class: ["a", "b"], data: {open: true}, aria: {label: "L"}))
  end

  def test_a_url_attribute_with_no_string_form_raises_as_in_phlex
    # Phlex 2.4.1 raises "Invalid attribute value" for a URL attribute given an
    # empty token list or a Hash, rather than omitting it.
    assert_raises(ArgumentError) { flat(href: []) }
    assert_raises(ArgumentError) { flat(src: {}) }
  end
end
