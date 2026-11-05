# frozen_string_literal: true

module RubyUI
  # Root of a select. Like Base UI's Select.Root it has no look of its own: it
  # holds the Stimulus controller, and SelectInput inside it carries the value.
  class Select < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "select",
          controller: "ruby-ui--select"
        }
      }
    end
  end
end
