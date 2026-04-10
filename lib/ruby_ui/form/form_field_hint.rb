# frozen_string_literal: true

module RubyUI
  class FormFieldHint
    include ComponentBase

    private

    def default_attrs
      {class: "empty:hidden text-sm text-muted-foreground"}
    end
  end
end
