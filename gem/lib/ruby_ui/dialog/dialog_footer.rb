# frozen_string_literal: true

module RubyUI
  class DialogFooter < Base
    def initialize(show_close_button: false, **attrs)
      @show_close_button = show_close_button
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        yield if block_given?
        close_button if @show_close_button
      end
    end

    private

    def default_attrs
      {
        class: "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end"
      }
    end

    def close_button
      Button(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) { "Close" }
    end
  end
end
