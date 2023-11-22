# frozen_string_literal: true

module PhlexUI
    class Typography::List < Base
        def initialize(items: [], numbered: false)
            @items = items
            @numbered = numbered
        end

        def template(&block)
            ul(**attrs) do
                if @items.empty?
                    block.call
                else
                    @items.each do |item|
                        PhlexUI::Typography::ListItem.new { item }
                    end
                end
            end
        end

        private

        def numbered? = @numbered

        def not_numbered? = !numbered?

        def default_attrs
            {
                class: tokens(
                    "my-6 ml-6 [&>li]:mt-2",
                    numbered?: "list-decimal",
                    not_numbered?: "list-disc"
                )
            }
        end
    end
end