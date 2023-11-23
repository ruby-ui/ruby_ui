# frozen_string_literal: true

class ApplicationLayout < ApplicationView
	include Phlex::Rails::Layout

	def template(&block)
		doctype

		html do
			render Shared::Head.new

			body do
				render Shared::Navbar.new
				main(&block)
			end
		end
	end
end
