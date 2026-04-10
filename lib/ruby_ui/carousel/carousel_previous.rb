# frozen_string_literal: true

module RubyUI
  class CarouselPrevious
    include ComponentBase

    def initialize(**attrs)
      merged = {
        class: [
          "absolute h-8 w-8 rounded-full",
          "group-[.is-horizontal]:-left-12 group-[.is-horizontal]:top-1/2 group-[.is-horizontal]:-translate-y-1/2",
          "group-[.is-vertical]:-top-12 group-[.is-vertical]:left-1/2 group-[.is-vertical]:-translate-x-1/2 group-[.is-vertical]:rotate-90"
        ],
        disabled: true,
        data: {
          action: "click->ruby-ui--carousel#scrollPrev",
          ruby_ui__carousel_target: "prevButton"
        }
      }.merge(attrs)
      btn = RubyUI::Button.new(variant: :outline, icon: true, **merged)
      @attrs = btn.attrs
    end

    attr_reader :attrs
  end
end
