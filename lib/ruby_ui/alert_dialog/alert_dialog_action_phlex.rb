# frozen_string_literal: true

module RubyUI
  class AlertDialogAction < Base
    def initialize(**attrs)
      btn = RubyUI::Button.new(variant: :primary, **attrs)
      @attrs = btn.attrs
    end
  end
end
