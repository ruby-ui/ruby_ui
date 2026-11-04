# frozen_string_literal: true

require "test_helper"

class RubyUI::PopoverTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Popover do
        RubyUI.PopoverTrigger do
          RubyUI.Button(variant: :outline) { "Open Popover" }
        end
        RubyUI.PopoverContent(align: :start) do
          RubyUI.PopoverHeader do
            RubyUI.PopoverTitle { "Dimensions" }
            RubyUI.PopoverDescription { "Set the dimensions for the layer." }
          end
        end
      end
    end

    assert_match(/Dimensions/, output)
    assert_match(/Set the dimensions for the layer\./, output)
  end

  def test_root_wires_the_controller
    output = phlex { RubyUI.Popover(open: true, options: {placement: "top"}) }

    root = tag(output, 'data-controller="ruby-ui--popover"')
    assert_equal "popover", root["data-slot"]
    assert_equal "true", root["data-ruby-ui--popover-open-value"]
    assert_equal({"placement" => "top"}, JSON.parse(root["data-ruby-ui--popover-options-value"]))
    refute root.key?("data-ruby-ui--popover-trigger-value"), "the open mode lives on PopoverTrigger now"
  end

  def test_root_is_closed_by_default
    output = phlex { RubyUI.Popover }

    assert_equal "false", tag(output, 'data-controller="ruby-ui--popover"')["data-ruby-ui--popover-open-value"]
  end

  # Opens on click unless the trigger asks for hover, as shadcn's does.
  def test_trigger_opens_on_click_by_default
    output = phlex { RubyUI.PopoverTrigger { "Open" } }

    trigger = tag(output, 'data-ruby-ui--popover-target="trigger"')
    assert_equal "popover-trigger", trigger["data-slot"]
    refute trigger.key?("data-open-on-hover")
    refute trigger.key?("data-delay")
  end

  def test_trigger_open_on_hover_with_delays
    output = phlex { RubyUI.PopoverTrigger(open_on_hover: true, delay: 100, close_delay: 50) { "Open" } }

    trigger = tag(output, 'data-ruby-ui--popover-target="trigger"')
    assert_equal "true", trigger["data-open-on-hover"]
    assert_equal "100", trigger["data-delay"]
    assert_equal "50", trigger["data-close-delay"]
  end

  # false must reach the controller so it beats the older options trigger: "hover".
  def test_trigger_open_on_hover_false_is_explicit
    trigger = tag(phlex { RubyUI.PopoverTrigger(open_on_hover: false) { "Open" } }, 'data-slot="popover-trigger"')

    assert_equal "false", trigger["data-open-on-hover"]
  end

  # A native popover in the top layer, closed until the controller opens it.
  def test_content_is_a_closed_dialog_popover
    output = phlex { RubyUI.PopoverContent { "popover body" } }

    content = tag(output, 'data-ruby-ui--popover-target="content"')
    assert_equal "manual", content["popover"]
    assert_equal "dialog", content["role"]
    assert_equal "-1", content["tabindex"]
    assert_equal "popover-content", content["data-slot"]
    assert_equal "closed", content["data-state"]
    assert content.key?("data-closed")
    assert_equal "4", content["data-side-offset"]
    assert_equal "0", content["data-align-offset"]
    assert_match(/popover body/, output)
  end

  # vega's cn-popover-content; display:flex must not show a closed popover.
  def test_content_has_vega_classes
    classes = tag(phlex { RubyUI.PopoverContent }, 'data-slot="popover-content"')["class"].split

    %w[bg-popover text-popover-foreground ring-1 ring-foreground/10 flex flex-col gap-4 rounded-md p-4
      text-sm shadow-md duration-100 w-72 origin-(--transform-origin) [&:not(:popover-open)]:hidden].each do |token|
      assert_includes classes, token
    end
    %w[border bg-background p-1 absolute].each { |token| refute_includes classes, token }
  end

  # The exit animation holds its last frame until the controller hides the popover.
  def test_content_holds_the_last_frame_of_the_exit_animation
    classes = tag(phlex { RubyUI.PopoverContent }, 'data-slot="popover-content"')["class"].split

    assert_includes classes, "data-closed:fill-mode-forwards"
  end

  def test_content_placement_props
    output = phlex { RubyUI.PopoverContent(side: :inline_end, align: :start, side_offset: 8, align_offset: 2) }

    content = tag(output, 'data-slot="popover-content"')
    assert_equal "inline-end", content["data-preferred-side"]
    assert_equal "start", content["data-preferred-align"]
    assert_equal "8", content["data-side-offset"]
    assert_equal "2", content["data-align-offset"]
  end

  def test_content_ignores_unknown_placement
    content = tag(phlex { RubyUI.PopoverContent(side: :middle, align: :sideways) }, 'data-slot="popover-content"')

    refute content.key?("data-preferred-side")
    refute content.key?("data-preferred-align")
  end

  def test_header_title_and_description
    output = phlex do
      RubyUI.PopoverHeader do
        RubyUI.PopoverTitle { "Dimensions" }
        RubyUI.PopoverDescription { "Set the dimensions." }
      end
    end

    assert_equal %w[flex flex-col gap-1 text-sm], tag(output, 'data-slot="popover-header"')["class"].split
    title = tag(output, 'data-slot="popover-title"', name: "h2")
    assert_equal "title", title["data-ruby-ui--popover-target"]
    assert_match(/\Apopover-title-\h{8}\z/, title["id"])
    assert_equal "font-medium", title["class"]
    description = tag(output, 'data-slot="popover-description"', name: "p")
    assert_equal "description", description["data-ruby-ui--popover-target"]
    assert_match(/\Apopover-description-\h{8}\z/, description["id"])
    assert_equal "text-muted-foreground", description["class"]
  end

  def test_title_keeps_a_caller_id
    title = tag(phlex { RubyUI.PopoverTitle(id!: "dims") { "Dimensions" } }, 'data-slot="popover-title"')

    assert_equal "dims", title["id"]
  end

  private

  # The attributes of the first tag containing needle (optionally of a given element).
  def tag(output, needle, name: nil)
    source = output.scan(/<[a-z0-9]+(?:[^>"]|"[^"]*")*>/).find { |t| t.include?(needle) && (name.nil? || t.start_with?("<#{name}")) }
    flunk "no tag with #{needle}" unless source
    source.scan(/([a-zA-Z_:-]+)(?:="([^"]*)")?/).drop(1).to_h { |k, v| [k, v && CGI.unescapeHTML(v)] }
  end
end
