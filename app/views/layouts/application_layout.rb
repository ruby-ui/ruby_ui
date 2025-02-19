# frozen_string_literal: true

class ApplicationLayout < Views::Base
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype

    html do
      render Shared::Head.new

      body do
        render Shared::Navbar.new
        main(&block)
        render Shared::Flashes.new(notice: flash[:notice], alert: flash[:alert])
      end
    end
  end
end
