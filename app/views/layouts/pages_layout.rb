# frozen_string_literal: true

class PagesLayout < ApplicationView
  include Phlex::Rails::Layout

  def template(&block)
    doctype

    html do
      render Shared::Head.new

      body do
        render Shared::Navbar.new
        main(class: "relative", &block)
        render Shared::Flashes.new(notice: helpers.flash[:notice], alert: helpers.flash[:alert])
      end
    end
  end
end
