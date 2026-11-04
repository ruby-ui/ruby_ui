# frozen_string_literal: true

module RubyUI
  # The toast's heading; the toast is named by it (aria-labelledby, wired by
  # the toast controller). Base UI renders an <h2>.
  class ToastTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {data: {slot: "toast-title"}, class: "text-sm font-medium"}
    end
  end
end
