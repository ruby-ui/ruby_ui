# frozen_string_literal: true

module RubyUI
  class AlertDialogTitle
    include ComponentBase

    private

    def default_attrs
      {class: "text-lg font-semibold"}
    end
  end
end
