# frozen_string_literal: true

class ApplicationLayout < ApplicationView
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype

    html do
      render Shared::Head.new

      body do
        render Shared::Navbar.new
        main(&block)
        render Shared::Flashes.new(notice: helpers.flash[:notice], alert: helpers.flash[:alert])
      end
    end
  end
end
