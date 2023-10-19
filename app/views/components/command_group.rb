# frozen_string_literal: true

class CommandGroup < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @title = attributes.delete(:title)
    end

    def template(&)
        div(
            class:
                "overflow-hidden p-1 text-foreground [&_[group-heading]]:px-2 [&_[group-heading]]:py-1.5 [&_[group-heading]]:text-xs [&_[group-heading]]:font-medium [&_[group-heading]]:text-muted-foreground",
            cmdk_group: "",
            role: "presentation",
            data_value: @title,
            data_command_target: "group",
        ) do
            render_header if @title
            div(group_items: "", role: "group") do
                yield
            end
        end
    end

    private

    def render_header
        div(group_heading: "", aria_hidden: "true") do
            @title
        end
    end
end