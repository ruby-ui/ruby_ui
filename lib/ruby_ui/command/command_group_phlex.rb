# frozen_string_literal: true

module RubyUI
  class CommandGroup < Base
    def initialize(title: nil, **attrs)
      @title = title
      super(**attrs)
    end

    attr_reader :title

    def view_template(&)
      div(**attrs) do
        if title

          div(group_heading: title) do
            title
          end

        end

        div(group_items: "", role: "group", &)
      end
    end

    private

    def default_attrs
      {
        class: "overflow-hidden p-1 text-foreground [&_[group-heading]]:px-2 [&_[group-heading]]:py-1.5 [&_[group-heading]]:text-xs [&_[group-heading]]:font-medium [&_[group-heading]]:text-muted-foreground",
        role: "presentation",
        data: {
          value: @title,
          ruby_ui__command_target: "group"
        }
      }
    end
  end
end
