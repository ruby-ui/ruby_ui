# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/carousel (strings in content.yml).
  class Carousel < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "p-16") do
        Carousel(class: "w-full max-w-xs") do
          CarouselContent do
            %w[1 2 3 4 5].each do |n|
              CarouselItem do
                div(class: "flex aspect-square items-center justify-center rounded-lg border p-6") do
                  span(class: "text-4xl font-semibold") { n }
                end
              end
            end
          end
          CarouselPrevious()
          CarouselNext(data: {audit_trigger: true})
        end
      end
    end
  end
end
