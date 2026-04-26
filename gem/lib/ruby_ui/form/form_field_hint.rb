# frozen_string_literal: true

module RubyUI
  class FormFieldHint < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {class: "empty:hidden text-sm text-muted-foreground"}
    end
  end
end
