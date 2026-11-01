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
    refute_match(/class="hidden\b|class="[^"]*\shidden\b/, output)
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

  def test_data_slot_on_every_part
    output = phlex do
      RubyUI.AvatarGroup do
        RubyUI.Avatar do
          RubyUI.AvatarImage(src: "/a.png")
          RubyUI.AvatarFallback { "A" }
          RubyUI.AvatarBadge
        end
        RubyUI.AvatarGroupCount { "+3" }
      end
    end

    %w[avatar-group avatar avatar-image avatar-fallback avatar-badge avatar-group-count].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
  end

  def test_default_size_matches_shadcn
    output = phlex { RubyUI.Avatar { RubyUI.AvatarFallback { "JD" } } }

    assert_match(/data-size="default"/, output)
    assert_match(/class="[^"]*\bsize-8\b/, output)
  end

  def test_sizes
    {xs: "size-4", sm: "size-6", default: "size-8", lg: "size-10", xl: "size-20"}.each do |size, klass|
      output = phlex { RubyUI.Avatar(size: size) }

      assert_match(/data-size="#{size}"/, output)
      assert_match(/class="[^"]*\b#{klass}\b/, output)
    end
  end

  def test_md_is_an_alias_of_default
    output = phlex { RubyUI.Avatar(size: :md) }

    assert_match(/data-size="default"/, output)
    assert_match(/\bsize-8\b/, output)
  end

  def test_unknown_or_nil_size_renders_default
    [nil, :huge, "sm"].each do |size|
      output = phlex { RubyUI.Avatar(size: size) }
      expected = (size == "sm") ? "sm" : "default"

      assert_match(/data-size="#{expected}"/, output)
    end
  end

  def test_image_crops_instead_of_stretching
    # object-cover keeps a non-square photo's aspect ratio (fill would stretch it).
    output = phlex { RubyUI.AvatarImage(src: "/wide.png") }

    assert_match(/\bobject-cover\b/, output)
    assert_match(/\brounded-full\b/, output)
  end

  def test_root_does_not_clip
    # The badge sits on the edge; the image and fallback round themselves.
    output = phlex { RubyUI.Avatar }

    refute_match(/overflow-hidden/, output)
    assert_match(/after:border-border/, output)
    assert_match(/select-none/, output)
  end

  def test_fallback_uses_muted_foreground
    output = phlex { RubyUI.AvatarFallback { "JD" } }

    assert_match(/text-muted-foreground/, output)
    assert_match(/\btext-sm\b/, output)
  end

  def test_fallback_delay
    # A delayed fallback starts hidden so it can't paint before the controller
    # connects and starts the timer.
    output = phlex { RubyUI.AvatarFallback(delay: 600) { "JD" } }
    assert_match(/data-delay="600"/, output)
    assert_match(/<span[^>]*\shidden[\s>]/, output)

    output = phlex { RubyUI.AvatarFallback { "JD" } }
    refute_match(/data-delay/, output)
    refute_match(/<span[^>]*\shidden[\s>]/, output)
  end

  def test_plain_img_child_is_sized_and_rounded
    # The root no longer clips, so Avatar { img(...) } still renders a round,
    # cropped photo.
    output = phlex { RubyUI.Avatar { |a| a.img(src: "/wide.png") } }

    assert_match(/\*:\[img\]:size-full/, output)
    assert_match(/\*:\[img\]:rounded-full/, output)
    assert_match(/\*:\[img\]:object-cover/, output)
  end

  def test_badge_keeps_both_ring_and_background
    output = phlex { RubyUI.AvatarBadge }

    assert_match(/\bbg-primary\b/, output)
    assert_match(/\bbg-blend-color\b/, output)
    assert_match(/\bring-background\b/, output)
  end
end
