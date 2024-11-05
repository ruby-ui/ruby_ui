# frozen_string_literal: true

require "test_helper"

class RubyUI::HoverCardTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
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
end
