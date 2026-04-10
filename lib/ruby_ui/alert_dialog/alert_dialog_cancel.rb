# frozen_string_literal: true

module RubyUI
  class AlertDialogCancel
    include ComponentBase

    def initialize(**attrs)
      merged_attrs = {
        data: {action: "click->ruby-ui--alert-dialog#dismiss"},
        class: "mt-2 sm:mt-0"
      }.merge(attrs)
      btn = RubyUI::Button.new(variant: :outline, **merged_attrs)
      @attrs = btn.attrs
    end

    attr_reader :attrs
  end
end
