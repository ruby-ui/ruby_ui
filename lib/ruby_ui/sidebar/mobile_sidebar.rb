# frozen_string_literal: true

module RubyUI
  class MobileSidebar
    include ComponentBase

    SIDEBAR_WIDTH_MOBILE = "18rem"

    def initialize(side: :left, **attrs)
      @side = side
      super(**attrs)
    end

    attr_reader :side

    private

    def default_attrs
      {
        data: {
          ruby_ui__sidebar_target: "mobileSidebar",
          action: "ruby--ui-sidebar:open->ruby-ui--sheet#open:self"
        }
      }
    end
  end
end
