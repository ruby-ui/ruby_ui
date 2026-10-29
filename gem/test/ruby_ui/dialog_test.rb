# frozen_string_literal: true

require "test_helper"

class RubyUI::DialogTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogTrigger do
          RubyUI.Button { "Open Dialog" }
        end
        RubyUI.DialogContent do
          RubyUI.DialogHeader do
            RubyUI.DialogTitle { "RubyUI to the rescue" }
            RubyUI.DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
          end
          RubyUI.DialogMiddle do
            RubyUI.AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do |aspect|
              aspect.img(
                alt: "Placeholder",
                loading: "lazy",
                src: "https://avatars.githubusercontent.com/u/246692?v=4"
              )
            end
          end
          RubyUI.DialogFooter do
            RubyUI.Button(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) { "Cancel" }
            RubyUI.Button { "Save" }
          end
        end
      end
    end

    assert_match(/Open Dialog/, output)
  end

  # Regression test for #343: Dialog content must use native <dialog> element, not <div>
  def test_dialog_content_renders_native_dialog_element
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/<dialog[\s>]/, output, "DialogContent must render a native <dialog> element")
    refute_match(/<template[\s>]/, output, "DialogContent must not use a <template> element")
  end

  def test_dialog_wrapper_renders_as_div_with_stimulus_controller
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-controller="ruby-ui--dialog"/, output)
    assert_match(/<div[^>]*data-controller="ruby-ui--dialog"/, output, "Dialog wrapper must be a <div>")
  end

  def test_dialog_content_has_stimulus_target
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-ruby-ui--dialog-target="dialog"/, output)
  end

  def test_dialog_content_has_backdrop_click_action
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-action="[^"]*click->ruby-ui--dialog#backdropClick/, output)
  end

  # Regression test for #570: the press must be tracked from pointerdown so clicks
  # on the panel's padding (or drags that end outside) don't dismiss the dialog.
  def test_dialog_content_tracks_backdrop_pointerdown
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-action="[^"]*pointerdown->ruby-ui--dialog#backdropPointerdown/, output)
  end

  # Regression test: a closed native <dialog> must stay hidden. The bare `flex`
  # utility (author CSS) overrides the UA `dialog:not([open]) { display: none }`,
  # making the dialog always visible. Display must be gated on the open: variant (open:grid).
  def test_dialog_content_does_not_force_display_when_closed
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    classes = output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
    refute_includes classes, "grid", "Bare `grid` forces a closed <dialog> to display; use `open:grid`"
    refute_includes classes, "flex", "Bare `flex` forces a closed <dialog> to display; use `open:grid`"
    assert_includes classes, "open:grid", "Dialog must apply grid only when open (open:grid)"
  end

  def test_dialog_content_sizes
    {xs: "max-w-sm", sm: "max-w-md", md: "max-w-lg", lg: "max-w-2xl", xl: "max-w-4xl", full: "max-w-full"}.each do |size, expected_class|
      output = phlex do
        RubyUI.Dialog do
          RubyUI.DialogContent(size: size) { "Content" }
        end
      end

      assert_match(/#{Regexp.escape(expected_class)}/, output, "Size #{size} should apply class #{expected_class}")
      refute_includes output, "max-w-[calc(100%-2rem)]", "Explicit size #{size} replaces the default width"
    end
  end

  def test_dialog_content_vega_classes
    classes = dialog_content_classes

    %w[open:grid gap-6 rounded-xl p-6 text-sm ring-1 ring-foreground/10 bg-popover text-popover-foreground outline-none].each do |klass|
      assert_includes classes, klass
    end
    %w[border shadow-lg gap-4 sm:rounded-lg bg-background].each do |klass|
      refute_includes classes, klass
    end
  end

  def test_dialog_content_overlay_classes
    classes = dialog_content_classes

    assert_includes classes, "backdrop:bg-black/10"
    assert_includes classes, "supports-backdrop-filter:backdrop:backdrop-blur-xs"
    refute_includes classes, "backdrop:bg-background/80"
  end

  def test_dialog_content_animation_classes
    classes = dialog_content_classes

    %w[
      data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95
      data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95
      duration-100
      data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0
      data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0
      data-[state=closed]:fill-mode-forwards data-[state=closed]:backdrop:fill-mode-forwards
      backdrop:duration-100
    ].each do |klass|
      assert_includes classes, klass
    end
    # `!` is required: the data-[state=…] animation rules carry an attribute selector,
    # so a plain `motion-reduce:animate-none` (one class) would lose on specificity.
    %w[motion-reduce:animate-none! motion-reduce:backdrop:animate-none!].each do |klass|
      assert_includes classes, klass
    end
    %w[open:animate-in duration-200].each do |klass|
      refute_includes classes, klass
    end
  end

  def test_dialog_content_default_width
    classes = dialog_content_classes

    assert_includes classes, "max-w-[calc(100%-2rem)]"
    assert_includes classes, "sm:max-w-md"
  end

  def test_dialog_title_is_h2_with_vega_classes
    output = render_dialog_part { RubyUI.DialogTitle { "Title" } }

    assert_match(/<h2[\s>]/, output)
    refute_match(/<h3[\s>]/, output)
    assert_match(/data-ruby-ui--dialog-target="title"/, output)
    classes = part_classes(output, "h2")
    %w[font-heading leading-none font-medium].each { |klass| assert_includes classes, klass }
    %w[text-lg font-semibold tracking-tight].each { |klass| refute_includes classes, klass }
  end

  def test_dialog_title_keeps_custom_data_attributes
    output = render_dialog_part { RubyUI.DialogTitle(data: {foo: "bar"}) { "Title" } }

    assert_match(/data-foo="bar"/, output)
    assert_match(/data-ruby-ui--dialog-target="title"/, output)
  end

  def test_dialog_description_link_classes
    output = render_dialog_part { RubyUI.DialogDescription { "Description" } }

    assert_match(/<p[\s>]/, output)
    assert_match(/data-ruby-ui--dialog-target="description"/, output)
    classes = part_classes(output, "p")
    %w[text-sm text-muted-foreground *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground].each do |klass|
      assert_includes classes, klass
    end
  end

  def test_dialog_description_keeps_custom_data_attributes
    output = render_dialog_part { RubyUI.DialogDescription(data: {foo: "bar"}) { "Description" } }

    assert_match(/data-foo="bar"/, output)
    assert_match(/data-ruby-ui--dialog-target="description"/, output)
  end

  def test_dialog_header_classes
    output = render_dialog_part { RubyUI.DialogHeader { "Header" } }

    assert_equal %w[flex flex-col gap-2], part_classes(output, "div")
  end

  def test_dialog_footer_classes
    output = render_dialog_part { RubyUI.DialogFooter { "Footer" } }

    assert_equal %w[flex flex-col-reverse gap-2 sm:flex-row sm:justify-end], part_classes(output, "div")
  end

  def test_dialog_open_value_is_set_on_wrapper
    output = phlex do
      RubyUI.Dialog(open: true) do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-ruby-ui--dialog-open-value/, output)
  end

  def test_close_button_has_dismiss_action
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-action="click->ruby-ui--dialog#dismiss"/, output)
  end

  def test_content_hides_close_button
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent(show_close_button: false) { "Content" }
      end
    end

    refute_includes output, 'sr-only">Close'
  end

  def test_content_close_button_vega_classes
    output = render_dialog_part { RubyUI.DialogContent { "Content" } }

    assert_includes output, "absolute top-4 right-4 size-8"
    assert_includes output, "hover:bg-muted"
    refute_includes output, "opacity-70"
  end

  def test_footer_close_button
    default = render_footer { RubyUI.DialogFooter { "Footer" } }
    refute_includes default, "dismiss"

    output = render_footer { RubyUI.DialogFooter(show_close_button: true) { "Footer" } }

    assert_includes output, "ruby-ui--dialog#dismiss"
    assert_match(/>Close<\/button>/, output)
    assert_operator output.index("Footer"), :<, output.index("Close")
  end

  def test_trigger_has_open_action
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogTrigger do
          RubyUI.Button { "Open" }
        end
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/data-action="click->ruby-ui--dialog#open"/, output)
  end

  def test_trigger_has_trigger_target
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogTrigger do
          RubyUI.Button { "Open" }
        end
        RubyUI.DialogContent { "Content" }
      end
    end

    assert_match(/<div [^<]*data-ruby-ui--dialog-target="trigger"[^<]*><button/, output)
  end

  private

  def render_dialog_part(&block)
    phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent(&block)
      end
    end
  end

  def render_footer(&block)
    phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent(show_close_button: false, &block)
      end
    end
  end

  def part_classes(output, tag)
    output[/<#{tag}\b[^>]*\sclass="([^"]*)"/, 1].to_s.split
  end

  def dialog_content_classes
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
  end
end
