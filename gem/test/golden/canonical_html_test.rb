# frozen_string_literal: true

require "test_helper"
require "golden/canonical_html"

# Adversarial tests for the normalizer: inputs a browser distinguishes that the
# canonical form must not conflate, and input it must refuse rather than
# silently truncate. Each of these compared equal on the ported code.
class GoldenCanonicalHtmlTest < Minitest::Test
  def canonical(html)
    Golden::CanonicalHtml.call(html)
  end

  def test_refuses_a_fragment_that_escapes_the_template_wrapper
    error = assert_raises(ArgumentError) do
      canonical("<div>safe</div></template><button>lost</button>")
    end

    assert_match(/escaped the <template> wrapper/, error.message)
  end

  def test_distinguishes_an_empty_element_from_a_whitespace_only_one
    # `:empty` matches only the first; `textContent` is truthy only on the second.
    refute_equal canonical(%(<div data-x="e"></div>)), canonical(%(<div data-x="e">\n</div>))
  end

  def test_whitespace_only_content_is_a_fixed_point
    once = canonical("<div>\n  \n</div>")

    assert_equal "<div> </div>\n", once
    assert_equal once, canonical(once)
  end

  def test_class_tokens_split_on_html_whitespace_only
    # U+000B is Ruby whitespace but not HTML whitespace: "a\vb" is one token.
    refute_equal canonical(%(<div class="a\vb"></div>)), canonical(%(<div class="a b"></div>))
  end

  def test_text_collapses_html_whitespace_only
    refute_equal canonical("<p>a\vb</p>"), canonical("<p>a b</p>")
  end

  def test_preserved_content_with_leading_newline_is_a_fixed_point
    # The parser drops one LF right after <pre>; the serializer must put it back
    # or the second pass eats a real blank line.
    once = canonical("<pre>\n\nfoo</pre>")

    assert_equal once, canonical(once)
    assert_equal "<pre>\n\nfoo</pre>\n", once
  end

  def test_preserved_leading_newline_that_a_browser_drops_stays_equal
    assert_equal canonical("<pre>\nfoo</pre>"), canonical("<pre>foo</pre>")
  end

  def test_plain_xmlns_declaration_is_not_prefixed
    once = canonical(%(<svg xmlns="http://www.w3.org/2000/svg"></svg>))

    assert_includes once, %( xmlns="http://www.w3.org/2000/svg")
    refute_includes once, "xmlns:xmlns"
    assert_equal once, canonical(once)
  end

  def test_prefixed_xmlns_declaration_keeps_its_prefix
    once = canonical(%(<svg xmlns:xlink="http://www.w3.org/1999/xlink"></svg>))

    assert_includes once, %(xmlns:xlink="http://www.w3.org/1999/xlink")
    assert_equal once, canonical(once)
  end

  def test_a_raw_text_element_inside_a_preserved_one_is_a_fixed_point
    once = canonical("<pre><script>if (a < b) {}</script></pre>")

    assert_equal once, canonical(once)
    assert_includes once, "a < b"
  end

  def test_a_pre_inside_a_pre_keeps_its_leading_newline
    once = canonical("<pre><pre>\n\nx</pre></pre>")

    assert_equal once, canonical(once)
    assert_includes once, "<pre>\n\nx</pre>"
  end

  def test_a_textarea_inside_a_pre_keeps_its_leading_newline
    once = canonical("<pre><textarea>\n\nx</textarea></pre>")

    assert_equal once, canonical(once)
    assert_includes once, "<textarea>\n\nx</textarea>"
  end

  def strict(html)
    Golden::CanonicalHtml.call(html, strict: true)
  end

  def test_strict_trims_only_html_whitespace_at_the_edges
    assert_equal "\vx\v", strict("\n\vx\v\n")
  end

  def test_strict_sees_whitespace_between_inline_siblings
    refute_equal strict("<span>a</span><span>b</span>"), strict("<span>a</span> <span>b</span>")
  end

  def test_strict_sees_whitespace_at_a_text_element_boundary
    refute_equal strict("<p>Hello <em>w</em></p>"), strict("<p>Hello<em>w</em></p>")
  end

  def test_strict_keeps_text_verbatim_and_still_sorts_attributes
    assert_equal %(<div class="a" id="x">\n  two  words\n</div>), strict(%(<div id="x" class="a">\n  two  words\n</div>))
  end

  def test_strict_trims_the_fragments_own_edges
    assert_equal "<b>x</b>", strict("\n  <b>x</b>\n")
  end

  def test_strict_is_a_fixed_point
    once = strict(%(<p>Hello <em>w</em>\n<code>a &lt; b</code></p>\n))

    assert_equal once, strict(once)
  end

  def test_strict_keeps_raw_text_elements_raw
    once = strict("<div><script>if (a < b) {}</script></div>")

    assert_equal once, strict(once)
    assert_includes once, "a < b"
  end

  def test_strict_restores_the_newline_the_parser_drops_after_pre_and_textarea
    %w[pre textarea].each do |tag|
      once = strict("<#{tag}>\n\nx</#{tag}>")

      assert_equal "<#{tag}>\n\nx</#{tag}>", once
      assert_equal once, strict(once)
    end
  end

  def test_strict_restores_it_for_a_nested_pre_too
    once = strict("<div><pre>\n\nx</pre></div>")

    assert_equal "<div><pre>\n\nx</pre></div>", once
    assert_equal once, strict(once)
  end
end
