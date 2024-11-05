# frozen_string_literal: true

module RubyUI
  class Command < Base
    def view_template(&)
      div(**attrs, &)
    end
  end
end
