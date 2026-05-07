# frozen_string_literal: true

module Views
  module Layouts
    class ExamplesLayout < Views::Base
      include Phlex::Rails::Layout

      def view_template(&block)
        doctype

        html do
          render Shared::Head.new

          body do
            block.call
            render Shared::Flashes.new(notice: flash[:notice], alert: flash[:alert])
          end
        end
      end
    end
  end
end
