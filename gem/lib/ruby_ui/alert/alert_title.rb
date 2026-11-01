# frozen_string_literal: true

module RubyUI
  class AlertTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "alert-title"},
        class: "font-medium group-has-[>svg]/alert:col-start-2 [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground"
      }
    end
  end
end
