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
end
