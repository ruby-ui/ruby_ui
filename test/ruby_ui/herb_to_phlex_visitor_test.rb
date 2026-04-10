# frozen_string_literal: true

require "test_helper"
require "herb"
require "ruby_ui/herb/herb_to_phlex_visitor"
require "ruby_ui/herb/phlex_generator"

class RubyUI::Herb::HerbToPhlexVisitorTest < Minitest::Test
  # ── Basic element tests ────────────────────────────────────────

  def test_simple_div
    phlex = generate("<div>Hello</div>")
    assert_includes phlex, "div"
    assert_includes phlex, 'plain "Hello"'
  end

  def test_void_element
    phlex = generate("<br>")
    assert_equal "br", phlex.strip
  end

  def test_void_element_with_attrs
    phlex = generate('<hr class="divider">')
    assert_includes phlex, "hr"
    assert_includes phlex, 'class: "divider"'
  end

  def test_self_closing_input
    phlex = generate('<input type="text" name="email">')
    assert_includes phlex, "input"
    assert_includes phlex, 'type: "text"'
    assert_includes phlex, 'name: "email"'
  end

  # ── Attribute tests ────────────────────────────────────────────

  def test_static_attributes
    phlex = generate('<div id="main" class="container">Content</div>')
    assert_includes phlex, 'id: "main"'
    assert_includes phlex, 'class: "container"'
  end

  def test_data_attribute_converts_dashes_to_underscores
    phlex = generate('<div data-controller="modal">X</div>')
    assert_includes phlex, "data_controller:"
  end

  def test_erb_attribute_value
    phlex = generate('<button class="<%= computed_classes %>">Click</button>')
    assert_includes phlex, "class: computed_classes"
    refute_includes phlex, "<%="
  end

  def test_multiple_erb_attributes
    phlex = generate('<button type="<%= @type %>" class="<%= classes %>">Go</button>')
    assert_includes phlex, "type: @type"
    assert_includes phlex, "class: classes"
  end

  # ── Yield / block tests ───────────────────────────────────────

  def test_yield_generates_block_param
    phlex = generate("<button><%= yield %></button>")
    # Should use the &block shorthand
    assert_match(/button.*&/, phlex)
    refute_includes phlex, "do\n"
  end

  def test_yield_with_attrs_generates_block_param
    phlex = generate('<button type="submit"><%= yield %></button>')
    assert_match(/button.*&/, phlex)
    assert_includes phlex, 'type: "submit"'
  end

  # ── ERB content tests ─────────────────────────────────────────

  def test_erb_output_tag
    phlex = generate("<p><%= @name %></p>")
    assert_includes phlex, "@name"
  end

  def test_erb_comment_becomes_ruby_comment
    phlex = generate("<%# This is a comment %><div>X</div>")
    assert_includes phlex, "# This is a comment"
  end

  # ── Nested elements ───────────────────────────────────────────

  def test_nested_elements
    phlex = generate('<div class="outer"><span class="inner">Text</span></div>')
    assert_includes phlex, "div"
    assert_includes phlex, "span"
    assert_includes phlex, 'plain "Text"'
  end

  # ── The actual Button template ────────────────────────────────

  def test_button_template
    template = File.read("lib/ruby_ui/button/button.html.erb")
    phlex = generate(template)

    # Should produce a button tag call with splat attrs
    assert_includes phlex, "button("
    assert_includes phlex, "**attrs"
    assert_match(/&/, phlex)
  end

  # ── PhlexGenerator integration ────────────────────────────────

  def test_phlex_generator_view_template
    template = '<section id="hero"><h1><%= @title %></h1></section>'
    body = RubyUI::Herb::PhlexGenerator.generate_view_template(template)

    assert_includes body, "section"
    assert_includes body, "h1"
    assert_includes body, "@title"
  end

  def test_phlex_generator_class
    template = "<div><%= yield %></div>"
    code = RubyUI::Herb::PhlexGenerator.generate_class(
      template_source: template,
      class_name: "Card",
      module_name: "RubyUI"
    )

    assert_includes code, "module RubyUI"
    assert_includes code, "class Card < Base"
    assert_includes code, "def view_template(&)"
    assert_includes code, "div"
  end

  def test_phlex_generator_raises_on_parse_error
    # Herb may not raise on malformed HTML (it's lenient), but if it does
    # report errors, the generator should raise.
    # This test documents the expected behavior.
    result = ::Herb.parse("<div>")
    if result.errors.any?
      assert_raises(ArgumentError) do
        RubyUI::Herb::PhlexGenerator.generate_view_template("<div>")
      end
    else
      # Herb is lenient — just verify it doesn't crash
      body = RubyUI::Herb::PhlexGenerator.generate_view_template("<div>")
      assert_kind_of String, body
    end
  end

  # ── HTML Output Parity ────────────────────────────────────────
  # Verify the generated Phlex code conceptually matches the hand-written
  # Button's view_template structure.

  def test_generated_button_matches_handwritten_structure
    template = File.read("lib/ruby_ui/button/button.html.erb")
    generated_body = generate(template)

    # Template uses tag_attributes(attrs) splat → visitor generates button(**attrs, &)
    assert_includes generated_body, "button("
    assert_includes generated_body, "**attrs"
    assert_match(/&\)?$/, generated_body.strip)
  end

  private

  def generate(source)
    result = ::Herb.parse(source)
    visitor = RubyUI::Herb::HerbToPhlexVisitor.new
    result.visit(visitor)
    visitor.to_phlex
  end
end
