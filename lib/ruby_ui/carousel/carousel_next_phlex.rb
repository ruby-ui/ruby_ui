# frozen_string_literal: true

module RubyUI
  class CarouselNext < Base
    def initialize(**attrs)
      merged = {
        class: [
          "absolute h-8 w-8 rounded-full",
          "group-[.is-horizontal]:-right-12 group-[.is-horizontal]:top-1/2 group-[.is-horizontal]:-translate-y-1/2",
          "group-[.is-vertical]:-bottom-12 group-[.is-vertical]:left-1/2 group-[.is-vertical]:-translate-x-1/2 group-[.is-vertical]:rotate-90"
        ],
        disabled: true,
        data: {
          action: "click->ruby-ui--carousel#scrollNext",
          ruby_ui__carousel_target: "nextButton"
        }
      }.merge(attrs)
      btn = RubyUI::Button.new(variant: :outline, icon: true, **merged)
      @attrs = btn.attrs
    end
  end
end
