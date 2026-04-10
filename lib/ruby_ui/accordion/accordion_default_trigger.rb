# frozen_string_literal: true

module RubyUI
  class AccordionDefaultTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--accordion#toggle"},
        class: "w-full flex flex-1 items-center justify-between py-4 text-sm font-medium transition-all hover:underline"
      }
    end
  end
end
