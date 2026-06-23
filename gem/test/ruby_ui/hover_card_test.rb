# frozen_string_literal: true

require "test_helper"

class RubyUI::HoverCardTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.HoverCard do
        RubyUI.HoverCardTrigger do
          RubyUI.Button(variant: :link) { "@joeldrapper" }
        end
        RubyUI.HoverCardContent do |card_content|
          card_content.div(class: "flex justify-between space-x-4") do
            RubyUI.Avatar do
              RubyUI.AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              RubyUI.AvatarFallback { "JD" }
            end
          end
        end
      end
    end

    assert_match(/joeldrapper/, output)
  end

  # Floating UI positions a real element in the DOM (tippy used to clone a
  # <template>). Content must render as a hidden, absolutely-positioned div.
  def test_content_renders_hidden_positioned_div_not_template
    output = phlex do
      RubyUI.HoverCardContent { "card body" }
    end

    refute_match(/<template/, output)
    assert_match(/hidden/, output)
    assert_match(/absolute/, output)
    assert_match(/card body/, output)
  end
end
