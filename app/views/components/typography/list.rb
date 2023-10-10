# frozen_string_literal: true

class Typography::List < ApplicationComponent
    include Phlex::DeferredRender

    def initialize(items: [])
		@items = items
	end

    def template
        ul(class: "my-6 ml-6 list-disc [&>li]:mt-2") do
            @items.each do |item|
                li(class: "leading-7") { item }
            end
        end
    end
end