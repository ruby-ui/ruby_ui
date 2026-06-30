# frozen_string_literal: true

module RubyUI
  class Message < Base
    def initialize(align: :start, **attrs)
      @align = align
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message", align: @align},
        class: "group/message relative flex w-full min-w-0 gap-2 text-sm data-[align=end]:flex-row-reverse"
      }
    end
  end
end
