# frozen_string_literal: true

module Views
  module Layouts
    class ApplicationLayout < Views::Base
      include Phlex::Rails::Layout

      def view_template(&block)
        doctype

        html do
          render Shared::Head.new

          body do
            script(defer: true, data_domain: "rubyui.com", src: "https://plausible.io/js/script.js")
            render Shared::Navbar.new
            main(&block)
            render Shared::Flashes.new(notice: flash[:notice], alert: flash[:alert])
          end
        end
      end
    end
  end
end
