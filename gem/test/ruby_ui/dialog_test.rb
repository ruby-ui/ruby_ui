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
  # making the dialog always visible. Display must be gated on the open: variant.
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

  def test_dialog_content_default_width
    classes = dialog_content_classes

    assert_includes classes, "max-w-[calc(100%-2rem)]"
    assert_includes classes, "sm:max-w-md"
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

  private

  def dialog_content_classes
    output = phlex do
      RubyUI.Dialog do
        RubyUI.DialogContent { "Content" }
      end
    end

    output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
  end
end
