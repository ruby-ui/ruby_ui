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
    assert_match(/class="aspect-square h-full w-full"/, output)
    refute_match(/class="[^"]*\bhidden\b[^"]*aspect-square/, output)
  end

  def test_image_is_not_lazy_loaded
    # Regression for #415: the controller hides a still-loading image with
    # display:none, and a loading="lazy" image with no box is never fetched, so
    # it would stay hidden forever. The avatar image must load eagerly.
    output = phlex do
      RubyUI.Avatar do
        RubyUI.AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
        RubyUI.AvatarFallback { "JD" }
      end
    end

    refute_match(/loading="lazy"/, output)
  end
end
