# frozen_string_literal: true

module RubyUI
  class AlertDialogAction
    include ComponentBase

    def initialize(**attrs)
      btn = RubyUI::Button.new(variant: :primary, **attrs)
      @attrs = btn.attrs
    end

    attr_reader :attrs
  end
end
