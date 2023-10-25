# frozen_string_literal: true

class PagesLayout < ApplicationView
	include Phlex::Rails::Layout

	def template(&block)
		doctype

		html do
			render Shared::Head.new

			body do
				render Shared::Navbar.new
			    main(class: 'relative', &block)
			end
		end
	end
end
