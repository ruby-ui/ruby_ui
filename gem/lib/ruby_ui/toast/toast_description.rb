# frozen_string_literal: true

module RubyUI
  # Secondary text; the toast is described by it (aria-describedby, wired by
  # the toast controller). Base UI renders a <p>.
  class ToastDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {data: {slot: "toast-description"}, class: "text-sm text-muted-foreground"}
    end
  end
end
