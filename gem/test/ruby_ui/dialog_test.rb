# frozen_string_literal: true

require "test_helper"

class RubyUI::DialogTest < ComponentTest
  DIALOG_WITH_CONTENT = %(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>)

  def test_render_with_all_items
    output = erb(<<~ERB)
      <%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogTrigger.new do %><%= render RubyUI::Button.new do %>Open Dialog<% end %><% end %><%= render RubyUI::DialogContent.new do %><%= render RubyUI::DialogHeader.new do %><%= render RubyUI::DialogTitle.new do %>RubyUI to the rescue<% end %><%= render RubyUI::DialogDescription.new do %>RubyUI helps you build accessible standard compliant web apps with ease<% end %><% end %><%= render RubyUI::DialogMiddle.new do %><%= render RubyUI::AspectRatio.new(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do %><img alt="Placeholder" loading="lazy" src="https://avatars.githubusercontent.com/u/246692?v=4"><% end %><% end %><%= render RubyUI::DialogFooter.new do %><%= render RubyUI::Button.new(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) do %>Cancel<% end %><%= render RubyUI::Button.new do %>Save<% end %><% end %><% end %><% end %>
    ERB

    assert_match(/Open Dialog/, output)
  end

  # Regression test for #343: Dialog content must use native <dialog> element, not <div>
  def test_dialog_content_renders_native_dialog_element
    output = erb(DIALOG_WITH_CONTENT)

    assert_match(/<dialog[\s>]/, output, "DialogContent must render a native <dialog> element")
    refute_match(/<template[\s>]/, output, "DialogContent must not use a <template> element")
  end

  def test_dialog_wrapper_renders_as_div_with_stimulus_controller
    output = erb(DIALOG_WITH_CONTENT)

    assert_match(/data-controller="ruby-ui--dialog"/, output)
    assert_match(/<div[^>]*data-controller="ruby-ui--dialog"/, output, "Dialog wrapper must be a <div>")
  end

  def test_dialog_content_has_stimulus_target
    assert_match(/data-ruby-ui--dialog-target="dialog"/, erb(DIALOG_WITH_CONTENT))
  end

  def test_dialog_content_has_backdrop_click_action
    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#backdropClick")}"/, erb(DIALOG_WITH_CONTENT))
  end

  # Regression test: a closed native <dialog> must stay hidden. The bare `flex`
  # utility (author CSS) overrides the UA `dialog:not([open]) { display: none }`,
  # making the dialog always visible. Display must be gated on the open: variant.
  def test_dialog_content_does_not_force_display_when_closed
    output = erb(DIALOG_WITH_CONTENT)

    classes = output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
    refute_includes classes, "flex", "Bare `flex` forces a closed <dialog> to display; use `open:flex`"
    assert_includes classes, "open:flex", "Dialog must apply flex only when open (open:flex)"
  end

  def test_dialog_content_sizes
    {xs: "max-w-sm", sm: "max-w-md", md: "max-w-lg", lg: "max-w-2xl", xl: "max-w-4xl", full: "max-w-full"}.each do |size, expected_class|
      output = erb(%(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogContent.new(size: #{size.inspect}) do %>Content<% end %><% end %>))

      assert_match(/#{Regexp.escape(expected_class)}/, output, "Size #{size} should apply class #{expected_class}")
    end
  end

  def test_dialog_open_value_is_set_on_wrapper
    output = erb(%(<%= render RubyUI::Dialog.new(open: true) do %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>))

    assert_match(/data-ruby-ui--dialog-open-value/, output)
  end

  def test_close_button_has_dismiss_action
    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#dismiss")}"/, erb(DIALOG_WITH_CONTENT))
  end

  def test_trigger_has_open_action
    output = erb(%(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogTrigger.new do %><%= render RubyUI::Button.new do %>Open<% end %><% end %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>))

    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#open")}"/, output)
  end

  # 2.0 coerces the size (spec decision B); 1.6 silently dropped the class for "lg".
  def test_dialog_content_size_accepts_the_string_form
    assert_equal erb(%(<%= render RubyUI::DialogContent.new(size: :lg) do %>b<% end %>)),
      erb(%(<%= render RubyUI::DialogContent.new(size: "lg") do %>b<% end %>))
  end

  def test_dialog_content_refuses_an_unknown_size
    error = assert_raises(ArgumentError) { RubyUI::DialogContent.new(size: :huge) }

    assert_match(/:xs, :sm, :md, :lg, :xl, :full/, error.message)
  end
end
