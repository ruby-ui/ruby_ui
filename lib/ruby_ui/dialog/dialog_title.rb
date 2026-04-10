# frozen_string_literal: true

module RubyUI
  class DialogTitle
    include ComponentBase

    private

    def default_attrs
      {
        class: "text-lg font-semibold leading-none tracking-tight"
      }
    end
  end
end
