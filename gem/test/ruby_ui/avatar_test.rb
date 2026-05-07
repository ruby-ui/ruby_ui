# frozen_string_literal: true

require "test_helper"

class RubyUI::AvatarTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Avatar do
        RubyUI.AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
        RubyUI.AvatarFallback { "JD" }
      end
    end

    assert_match(/joeldrapper/, output)
    assert_match(/data-controller="ruby-ui--avatar"/, output)
    assert_match(/data-ruby-ui--avatar-target="image"/, output)
    assert_match(/load->ruby-ui--avatar#showImage error->ruby-ui--avatar#showFallback/, output)
    assert_match(/data-ruby-ui--avatar-target="fallback"/, output)
    assert_match(/hidden aspect-square/, output)
  end
end
