# frozen_string_literal: true

module RubyUI
  class SelectContent < Base
    def initialize(**attrs)
      @id = "content#{SecureRandom.hex(4)}"
      super
    end

    def view_template(&block)
      div(**attrs) do
        div(
          class: "max-h-96 w-full text-wrap overflow-auto rounded-md border bg-background p-1 text-foreground shadow-md animate-out group-data-[ruby-ui--select-open-value=true]/select:animate-in fade-out-0 group-data-[ruby-ui--select-open-value=true]/select:fade-in-0 zoom-out-95 group-data-[ruby-ui--select-open-value=true]/select:zoom-in-95 slide-in-from-top-2", &block
        )
      end
    end

    private

    def default_attrs
      {
        id: @id,
        role: "listbox",
        tabindex: "-1",
        data: {
          ruby_ui__select_target: "content"
        },
        class: "hidden w-full absolute top-0 left-0 z-50"
      }
    end
  end
end
