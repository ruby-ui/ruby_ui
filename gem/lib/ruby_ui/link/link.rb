# frozen_string_literal: true

module RubyUI
  # A link styled like a button, after shadcn's Button rendered as <a>
  # (Base UI + vega). It reuses Button's classes, so variant: and size: take
  # the same values (default :primary, as shadcn; variant: :link for a text
  # link).
  #
  # Unlike Button(href:), it keeps native link semantics: role link, Enter
  # follows it, no JS. Base UI's Button docs say links shouldn't be rendered
  # as buttons, and to style the <a> instead.
  #
  # disabled: true drops the href (ARIA in HTML: to convey a disabled link,
  # remove the href) and renders <a role="link" aria-disabled="true">: out of
  # the tab order, can't be followed, dimmed. focusable_when_disabled: true
  # keeps it in the tab order (tabindex 0), still without an href.
  class Link < Base
    DISABLED = "aria-disabled:pointer-events-none aria-disabled:opacity-50"

    def initialize(href: "#", variant: :primary, size: :md, icon: false,
      disabled: false, focusable_when_disabled: false, **attrs)
      @href = href
      @variant = variant.to_s.to_sym
      @variant = Button::VARIANT_ALIASES.fetch(@variant, @variant)
      @variant = :primary unless Button::VARIANTS.key?(@variant)
      size = size.to_s.tr("-", "_").to_sym
      @icon = icon || size.start_with?("icon")
      @size = Button::SIZE_ALIASES.fetch(size, size)
      @size = :md unless Button::SIZES.key?(@size)
      @disabled = disabled
      @focusable_when_disabled = focusable_when_disabled
      super(**attrs)
      # mix concatenates strings: a caller's own aria: {disabled: "true"}
      # would otherwise become "true true".
      @attrs[:aria][:disabled] = "true" if @disabled
    end

    def view_template(&)
      a(**attrs, &)
    end

    private

    def default_attrs
      sizes = @icon ? Button::ICON_SIZES : Button::SIZES
      attrs = {
        class: [Button::BASE, sizes.fetch(@size), Button::VARIANTS.fetch(@variant), DISABLED],
        data: {slot: "button"}
      }

      if @disabled
        attrs[:role] = "link"
        attrs[:aria] = {disabled: "true"}
        attrs[:tabindex] = 0 if @focusable_when_disabled
      else
        attrs[:href] = @href
      end

      attrs
    end
  end
end
