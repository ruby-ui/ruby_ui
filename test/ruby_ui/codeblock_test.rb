# frozen_string_literal: true

require "test_helper"

class RubyUI::CodeblockTest < Minitest::Test
  def setup
    @code = <<~CODE
      def hello_world
        puts "Hello, world!"
      end
    CODE
  end

  def test_not_phlex
    refute RubyUI::Codeblock.new(@code, syntax: :ruby).is_a?(Phlex::HTML)
  end

  def test_has_default_class
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert_includes cb.attrs[:class], "highlight"
    assert_includes cb.attrs[:class], "font-mono"
    assert_includes cb.attrs[:class], "rounded-md"
  end

  def test_clipboard_true_by_default
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert cb.clipboard?
  end

  def test_clipboard_false
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby, clipboard: false)
    refute cb.clipboard?
  end

  def test_syntax_stored
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert_equal :ruby, cb.syntax
  end

  def test_highlighted_code_contains_content
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert_includes cb.highlighted_code, "hello_world"
  end

  def test_rouge_css_not_empty
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert cb.rouge_css.length > 0
  end

  def test_ruby_code_tabs_converted
    cb = RubyUI::Codeblock.new("def x\n  y\nend", syntax: :ruby)
    assert_includes cb.code, "\t"
  end

  def test_custom_messages
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby, clipboard_success: "Yep!", clipboard_error: "Nope!")
    assert_equal "Yep!", cb.clipboard_success
    assert_equal "Nope!", cb.clipboard_error
  end

  def test_style_attr
    cb = RubyUI::Codeblock.new(@code, syntax: :ruby)
    assert_equal({tab_size: 2}, cb.attrs[:style])
  end
end
