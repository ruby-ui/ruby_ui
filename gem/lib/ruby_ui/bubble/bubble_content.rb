# frozen_string_literal: true

module RubyUI
  class BubbleContent < Base
    def initialize(as: :div, **attrs)
      @as = as
      super(**attrs)
    end

    def view_template(&)
      send(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "bubble-content"},
        class: "w-fit max-w-full min-w-0 overflow-hidden wrap-break-word rounded-3xl border border-transparent px-3 py-2.5 text-sm leading-relaxed group-data-[align=end]/bubble:self-end [&:is(button,a)]:text-left [&:is(button,a)]:outline-none [&:is(button,a)]:transition-colors [&:is(button,a):focus-visible]:border-ring [&:is(button,a):focus-visible]:ring-3 [&:is(button,a):focus-visible]:ring-ring/30"
      }
    end
  end
end
