# frozen_string_literal: true

require "test_helper"

class RubyUI::MessageTest < ComponentTest
  def test_renders_message_with_bubble
    output = phlex do
      RubyUI.Message do
        RubyUI.MessageContent do
          RubyUI.Bubble { RubyUI.BubbleContent { "Hi" } }
        end
      end
    end

    assert_match(/data-slot="message"/, output)
    assert_match(/data-slot="message-content"/, output)
    assert_match(/data-slot="bubble"/, output)
    assert_match(/Hi/, output)
  end

  def test_default_align_start
    output = phlex { RubyUI.Message { "x" } }

    assert_match(/data-align="start"/, output)
  end

  def test_align_end
    output = phlex { RubyUI.Message(align: :end) { "x" } }

    assert_match(/data-align="end"/, output)
  end

  def test_avatar_header_footer_slots
    output = phlex do
      RubyUI.Message do
        RubyUI.MessageAvatar { "A" }
        RubyUI.MessageContent do
          RubyUI.MessageHeader { "Oliver" }
          RubyUI.Bubble { RubyUI.BubbleContent { "Hi" } }
          RubyUI.MessageFooter { "Delivered" }
        end
      end
    end

    assert_match(/data-slot="message-avatar"/, output)
    assert_match(/data-slot="message-header"/, output)
    assert_match(/data-slot="message-footer"/, output)
  end

  def test_group_wraps_messages
    output = phlex do
      RubyUI.MessageGroup do
        RubyUI.Message { "a" }
        RubyUI.Message { "b" }
      end
    end

    assert_match(/data-slot="message-group"/, output)
  end
end
