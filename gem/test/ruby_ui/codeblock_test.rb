# frozen_string_literal: true

require "test_helper"

class RubyUI::CodeblockTest < ComponentTest
  CODE = <<~CODE
    def hello_world
      puts "Hello, world!"
    end
  CODE

  def test_shorthand_renders_root_actions_and_content
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby) }

    assert_match(/data-slot="code-block" data-variant="default" data-size="default" data-controller="ruby-ui--codeblock"/, output)
    assert_match(/data-slot="code-block-actions"/, output)
    assert_match(/data-slot="code-block-copy-button" /, output)
    assert_match(/<pre dir="ltr" tabindex="0"/, output)
    assert_match(/<code data-slot="code-block-code"/, output)
    assert_match(/<span class="nf">hello_world<\/span>/, output)
    assert_operator output.index(%(data-slot="code-block-actions")), :<, output.index(%(data-slot="code-block-content"))
  end

  def test_shorthand_keeps_indentation_as_spaces
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby) }

    assert_includes output, "\n  <span class=\"nb\">puts</span>"
    refute_includes output, "\t"
  end

  def test_highlighted_code_is_one_grid_item
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby, clipboard: false) }

    assert_match(/<code data-slot="code-block-code"[^>]*><span><span class="k">def<\/span>/, output)
  end

  def test_no_inline_style_element
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby) }

    refute_match(/<style/, output)
  end

  def test_clipboard_false_drops_the_copy_button
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby, clipboard: false) }

    refute_match(/code-block-actions/, output)
    refute_match(/code-block-copy-button/, output)
  end

  def test_copy_button_has_accessible_name_value_and_live_region
    output = phlex { RubyUI.Codeblock("a < b", syntax: :ruby, clipboard_success: "Nice one!") }

    assert_match(/aria-label="Copy"/, output)
    assert_match(/data-value="a < b"/, output)
    assert_match(/data-copied-label="Nice one!"/, output)
    assert_match(/data-error-label="Copy failed"/, output)
    assert_match(/data-action="ruby-ui--codeblock#copy"/, output)
    assert_match(/<span aria-live="polite" class="sr-only" data-slot="code-block-copy-status"><\/span>/, output)
  end

  def test_variant_and_size
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby, variant: :destructive, size: :sm) }

    assert_match(/data-variant="destructive" data-size="sm"/, output)
    assert_match(/border-destructive\/30/, output)
  end

  def test_unknown_variant_and_size_fall_back_to_default
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby, variant: :nope, size: :xl) }

    assert_match(/data-variant="default" data-size="default"/, output)
  end

  def test_line_numbers_render_one_line_per_code_line
    output = phlex { RubyUI.Codeblock("a\n\nb\n", syntax: :ruby, line_numbers: true, start_line: 5) }

    assert_match(/data-numbered/, output)
    assert_match(/counter-reset: line 4/, output)
    assert_equal 3, output.scan('data-slot="code-block-line"').size
    assert_match(%r{<span data-slot="code-block-line-content" class="min-w-0">\n</span>}, output)
  end

  def test_custom_style_keeps_counter_reset
    hash = phlex { RubyUI.CodeblockContent("a", start_line: 10, style: {max_height: "200px"}) }
    string = phlex { RubyUI.CodeblockContent("a", start_line: 10, style: "max-height:200px") }

    assert_includes hash, 'style="counter-reset: line 9; max-height: 200px;"'
    assert_includes string, 'style="counter-reset: line 9; max-height:200px;"'
  end

  def test_wrap
    output = phlex { RubyUI.Codeblock(CODE, syntax: :ruby, wrap: true) }

    assert_match(/data-wrap/, output)
  end

  def test_unknown_syntax_falls_back_to_plain_text
    output = phlex { RubyUI.Codeblock("<b>hi</b>", syntax: :not_a_language, clipboard: false) }

    assert_includes output, "&lt;b&gt;hi&lt;/b&gt;"
  end

  def test_composition
    output = phlex do
      RubyUI.Codeblock do
        RubyUI.CodeblockHeader do
          RubyUI.CodeblockTitle { "app.rb" }
          RubyUI.CodeblockActions { RubyUI.CodeblockCopyButton(value: "x") }
        end
        RubyUI.CodeblockContent do
          RubyUI.CodeblockLine(variant: :removed) { "old" }
          RubyUI.CodeblockLine(variant: :added) { "new" }
        end
        RubyUI.CodeblockFooter { "Ruby" }
      end
    end

    %w[code-block-header code-block-title code-block-footer].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
    assert_match(/data-slot="code-block-line" data-variant="removed"/, output)
    assert_match(/data-slot="code-block-line" data-variant="added"/, output)
    assert_match(/app\.rb/, output)
  end

  def test_theme_renders_light_and_dark_rules_without_base_background
    output = phlex { RubyUI.CodeblockTheme }

    assert_match(/<style>/, output)
    assert_match(/\[data-slot=code-block-code\] \.k/, output)
    assert_match(/\.dark \[data-slot=code-block-code\] \.k/, output)
    refute_match(/\[data-slot=code-block-code\], \[data-slot=code-block-code\] \.w \{/, output)
  end
end
