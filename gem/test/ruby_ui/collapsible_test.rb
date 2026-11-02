# frozen_string_literal: true

require "test_helper"

class RubyUI::CollapsibleTest < ComponentTest
  def render_collapsible(trigger: {}, content: {}, **root)
    phlex do
      RubyUI.Collapsible(**root) do
        RubyUI.CollapsibleTrigger(**trigger) { "Toggle" }
        RubyUI.CollapsibleContent(**content) { "Hidden text" }
      end
    end
  end

  def test_closed_by_default
    output = render_collapsible

    assert_match(/<div data-slot="collapsible"[^>]*data-ruby-ui--collapsible-open-value="false"/, output)
    assert_match(/data-slot="collapsible"[^>]*data-closed/, output)
    refute_match(/data-slot="collapsible"[^>]*data-open(?!-)/, output)
    assert_match(/<button[^>]*type="button"[^>]*data-slot="collapsible-trigger"|<button[^>]*data-slot="collapsible-trigger"[^>]*type="button"/, output)
    assert_match(/aria-expanded="false"/, output)
    refute_match(/data-panel-open/, output)
    assert_match(/<div[^>]*data-slot="collapsible-content"[^>]*hidden/, output)
  end

  def test_open_renders_open_state_from_the_server
    output = render_collapsible(open: true)

    assert_match(/data-ruby-ui--collapsible-open-value="true"/, output)
    assert_match(/aria-expanded="true"/, output)
    assert_match(/data-panel-open/, output)
    refute_match(/data-slot="collapsible-content"[^>]*hidden/, output)
    refute_match(/data-closed/, output)
  end

  def test_trigger_controls_content
    output = render_collapsible

    content_id = output[/data-slot="collapsible-content"[^>]*id="([^"]+)"|id="([^"]+)"[^>]*data-slot="collapsible-content"/, 1] ||
      output[/id="([^"]+)"[^>]*data-slot="collapsible-content"/, 1]
    assert content_id
    assert_match(/aria-controls="#{content_id}"/, output)
  end

  def test_content_keeps_a_caller_id
    output = render_collapsible(content: {id: "repos"})

    assert_match(/id="repos"/, output)
    assert_match(/aria-controls="collapsible-content-/, output)
  end

  def test_content_has_no_default_overflow_class
    output = render_collapsible

    refute_match(/overflow-y-hidden/, output)
  end

  def test_hidden_until_found
    output = render_collapsible(content: {hidden_until_found: true})

    assert_match(/hidden="until-found"/, output)
    assert_match(/data-hidden-until-found/, output)
  end

  def test_disabled
    output = render_collapsible(disabled: true)

    assert_match(/data-ruby-ui--collapsible-disabled-value="true"/, output)
    assert_match(/data-slot="collapsible"[^>]*data-disabled/, output)
    assert_match(/<button[^<]* disabled[ >]/, output)
  end

  def test_trigger_as_button
    output = render_collapsible(trigger: {variant: :ghost, icon: true, size: :sm})

    assert_match(/<button[^>]*data-slot="collapsible-trigger"/, output)
    refute_match(/data-slot="button/, output)
    assert_match(/h-8 w-8/, output)
    assert_match(/data-action="click->ruby-ui--collapsible#toggle"/, output)
    assert_match(/aria-expanded="false"/, output)
  end

  def test_trigger_as_button_disabled
    output = render_collapsible(disabled: true, trigger: {variant: :outline})

    assert_match(/<button[^<]* disabled[ >]/, output)
  end

  def test_trigger_size_alone_renders_a_button
    output = render_collapsible(trigger: {size: :sm})

    assert_match(/h-8 gap-1/, output)
    assert_match(/hover:bg-muted/, output)
  end

  def test_trigger_keeps_its_own_disabled
    plain = render_collapsible(trigger: {disabled: true})
    styled = render_collapsible(trigger: {variant: :outline, disabled: true})

    assert_match(/<button[^<]* disabled[ >]/, plain)
    assert_match(/<button[^<]* disabled[ >]/, styled)
    refute_match(/data-slot="collapsible"[^>]*data-disabled/, plain)
  end
end
