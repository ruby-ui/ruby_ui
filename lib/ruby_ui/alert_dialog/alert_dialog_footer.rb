# frozen_string_literal: true

module RubyUI
  class AlertDialogFooter
    include ComponentBase

    private

    def default_attrs
      {class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 rtl:space-x-reverse"}
    end
  end
end
