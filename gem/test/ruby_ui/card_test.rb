# frozen_string_literal: true

require "test_helper"

class RubyUI::CardTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Card(class: "w-96") do
        RubyUI.CardHeader do
          RubyUI.CardTitle { 'You might like "RubyUI"' }
          RubyUI.CardDescription { "@joeldrapper" }
          RubyUI.CardAction { "Follow" }
        end
        RubyUI.CardContent { "Body" }
        RubyUI.CardFooter { "Footer" }
      end
    end

    assert_match(/You might like/, output)
    {
      "card" => "div", "card-header" => "div", "card-title" => "div", "card-description" => "div",
      "card-action" => "div", "card-content" => "div", "card-footer" => "div"
    }.each do |slot, tag|
      assert_match(/<#{tag}\b[^>]*\bdata-slot="#{slot}"/, output, "#{slot} on <#{tag}>")
    end
    refute_match(/<h3|<p\b/, output)
  end

  def test_card_owns_the_spacing
    output = phlex { RubyUI.Card { "Hi" } }

    assert_match(/data-size="default"/, output)
    assert_match(/flex flex-col gap-\(--card-spacing\)/, output)
    assert_match(/py-\(--card-spacing\)/, output)
    assert_match(/\[--card-spacing:--spacing\(6\)\] data-\[size=sm\]:\[--card-spacing:--spacing\(4\)\]/, output)
    assert_match(%r{ring-1 ring-foreground/10}, output)
    assert_match(/bg-card/, output)
    refute_match(/\bborder\b|bg-background/, output)
  end

  def test_parts_pad_only_their_sides
    {
      RubyUI::CardHeader => "card-header", RubyUI::CardContent => "card-content", RubyUI::CardFooter => "card-footer"
    }.each do |klass, slot|
      output = phlex { render klass.new { "x" } }

      assert_match(/px-\(--card-spacing\)/, output, slot)
      refute_match(/\bp-6\b|\bpt-0\b/, output, slot)
    end
  end

  def test_footer_is_a_flex_row
    output = phlex { RubyUI.CardFooter { "x" } }

    assert_match(/class="flex items-center/, output)
  end

  def test_small_size_reaches_the_title
    output = phlex do
      RubyUI.Card(size: :sm) do
        RubyUI.CardHeader { RubyUI.CardTitle { "Title" } }
      end
    end

    card = output[/<div[^>]*data-slot="card"[^>]*>/]
    title = output[/<div[^>]*data-slot="card-title"[^>]*>/]
    assert_match(/data-size="sm"/, card)
    assert_match(%r{class="group/card }, card)
    assert_match(%r{group-data-\[size=sm\]/card:text-sm}, title)
  end

  def test_card_does_not_clip_popups
    output = phlex { RubyUI.Card { "Hi" } }

    refute_match(/overflow-hidden/, output)
  end

  def test_unknown_size_falls_back_to_default
    [nil, :lg, "sm "].each do |size|
      output = phlex { RubyUI.Card(size: size) { "Hi" } }

      assert_match(/data-size="default"/, output, "size #{size.inspect}")
    end
  end

  def test_title_follows_the_card_size
    output = phlex { RubyUI.CardTitle { "Title" } }

    assert_match(%r{font-heading text-base leading-normal font-medium group-data-\[size=sm\]/card:text-sm}, output)
  end

  def test_action_sits_in_the_header_second_column
    header = phlex { RubyUI.CardHeader { "x" } }
    action = phlex { RubyUI.CardAction { "x" } }

    assert_match(/has-data-\[slot=card-action\]:grid-cols-\[1fr_auto\]/, header)
    assert_match(/col-start-2 row-span-2 row-start-1 self-start justify-self-end/, action)
  end

  def test_user_classes_override_spacing
    output = phlex { RubyUI.Card(class: "p-8 gap-6") { "Hi" } }

    assert_match(/\bp-8\b/, output)
    refute_match(/py-\(--card-spacing\)|gap-\(--card-spacing\)/, output)
  end
end
