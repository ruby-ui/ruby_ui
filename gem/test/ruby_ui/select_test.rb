# frozen_string_literal: true

require "test_helper"

class RubyUI::SelectTest < ComponentTest
  def test_render_with_all_items
    output = erb(<<~ERB)
      <%= render RubyUI::Select.new do %><%= render RubyUI::SelectInput.new(name: "NAME") %><%= render RubyUI::SelectTrigger.new do %><%= render RubyUI::SelectValue.new(placeholder: "Placeholder") %><% end %><%= render RubyUI::SelectContent.new(outlet_id: "1") do %><%= render RubyUI::SelectGroup.new do %><% [["John Doe", 1], ["Jane Doe", 2], ["Sam Smith", 3]].each do |name, id| %><%= render RubyUI::SelectItem.new(value: id) do %><%= name %><% end %><% end %><% end %><% end %><% end %>
    ERB

    assert_match(/John/, output)
    assert_match('name="NAME"', output)
  end

  def test_select_value_renders_placeholder_when_block_returns_nil
    output = erb(%(<%= render(RubyUI::SelectValue.new(placeholder: "Placeholder")) { nil } %>))

    assert_match(/Placeholder/, output)
  end

  # Phlex wrote the placeholder only when the block emitted nothing; a
  # whitespace-only block is content (probe 25).
  def test_select_value_renders_placeholder_when_block_is_empty
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %><% end %>))

    assert_match(/>Placeholder</, output)
  end

  def test_select_value_keeps_whitespace_only_content
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %> <% end %>))

    assert_match(/> </, output)
    refute_match(/Placeholder/, output)
  end

  def test_select_value_renders_its_content_over_the_placeholder
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %>Apple<% end %>))

    assert_match(/>Apple</, output)
    refute_match(/Placeholder/, output)
  end

  # `hidden` lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = erb(%(<%= render RubyUI::SelectContent.new do %>options<% end %>))

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end
end
