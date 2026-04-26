# frozen_string_literal: true

module RubyUI
  class PaginationItem < Base
    def initialize(href: "#", active: false, **attrs)
      @href = href
      @active = active
      super(**attrs)
    end

    def view_template(&block)
      li do
        a(href: @href, **attrs, &block)
      end
    end

    private

    def default_attrs
      {
        aria: {current: @active ? "page" : nil},
        class: [
          RubyUI::Button.new(variant: @active ? :outline : :ghost).attrs[:class]
        ]
      }
    end
  end
end
