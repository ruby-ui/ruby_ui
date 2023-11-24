module Mailers
    class ApplicationMailer < Phlex::HTML
        def before_template
            style { "body { font-family: Helvetica, sans-serif; }" }
            super
        end
    end
end