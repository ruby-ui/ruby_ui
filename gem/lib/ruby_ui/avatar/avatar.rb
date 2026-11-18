# frozen_string_literal: true

module RubyUI
  # A round image with a text fallback, like shadcn's Avatar. The size is
  # exposed as data-size so the parts (fallback text, badge) follow it.
  class Avatar < Base
    SIZES = {
      xs: "size-4",
      sm: "size-6",
      default: "size-8",
      lg: "size-10",
      xl: "size-20"
    }.freeze
    # :md was the default before RubyUI matched shadcn's size names.
    ALIASES = {md: :default}.freeze

    def initialize(size: :default, **attrs)
      @size = size.to_s.to_sym
      @size = ALIASES.fetch(@size, @size)
      @size = :default unless SIZES.key?(@size) # nil or unknown: default size
      super(**attrs)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "avatar",
          size: @size,
          controller: "ruby-ui--avatar"
        },
        class: [
          "group/avatar relative flex shrink-0 select-none rounded-full",
          "after:absolute after:inset-0 after:rounded-full after:border after:border-border after:mix-blend-darken dark:after:mix-blend-lighten",
          SIZES.fetch(@size)
        ]
      }
    end
  end
end
