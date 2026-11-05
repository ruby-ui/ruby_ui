# frozen_string_literal: true

module RubyUI
  # One page link: shadcn's PaginationItem (<li>) and PaginationLink (<a>) in
  # one part. Attributes go to the <a>. It stays a plain link (no
  # role="button"): it navigates.
  #
  # size: takes Button sizes. The default, :icon, makes a 36px square for a
  # page number, as in shadcn; pass size: :default for a link with text.
  class PaginationItem < Base
    def initialize(href: "#", active: false, size: :icon, **attrs)
      @href = href
      @active = active
      @size = size
      super(**attrs)
    end

    def view_template(&)
      li(data: {slot: "pagination-item"}) do
        a(href: @href, **attrs, &)
      end
    end

    private

    def default_attrs
      {
        aria: {current: @active ? "page" : nil},
        data: {slot: "pagination-link", active: @active ? "true" : nil},
        class: [
          RubyUI::Button.new(variant: @active ? :outline : :ghost, size: @size).attrs[:class]
        ]
      }
    end
  end
end
