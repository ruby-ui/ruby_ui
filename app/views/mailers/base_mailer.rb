# Provides helper method for rendering CTA links

module Mailers
  class BaseMailer < Phlex::HTML    
    private

    def para(&)
      p(&) # See mailer_layout.rb to change styles
    end

    def subheader(&)
      h2(&) # See mailer_layout.rb to change styles
    end

    def cta(href:, &block)
      table(
        role: "presentation",
        border: "0",
        cellpadding: "0",
        cellspacing: "0",
        class: "btn btn-primary"
      ) do
        tbody do
          tr do
            td(align: "left") do
              table(
                role: "presentation",
                border: "0",
                cellpadding: "0",
                cellspacing: "0"
              ) do
                tbody do
                  tr do
                    td do
                      a(
                        href: href,
                        target: "_blank"
                      ) { block.call }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end