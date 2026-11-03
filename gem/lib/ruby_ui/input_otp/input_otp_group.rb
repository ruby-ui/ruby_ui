# frozen_string_literal: true

module RubyUI
  class InputOtpGroup < Base
    def view_template(&block)
      div(**attrs, &block)
    end

    private

    def default_attrs
      {
        data: {slot: "input-otp-group"},
        class: "flex items-center rounded-md has-aria-invalid:border-destructive has-aria-invalid:ring-3 has-aria-invalid:ring-destructive/20 dark:has-aria-invalid:ring-destructive/40"
      }
    end
  end
end
