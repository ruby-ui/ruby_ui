# frozen_string_literal: true

class DocsLayout < ApplicationView
	include Phlex::Rails::Layout

	def template(&block)
		doctype

		html do
			render Shared::Head.new

			body do
				render Shared::Navbar.new
				div(class: 'flex-1') do
					div(class: 'border-b') do
						div(class: 'container px-4 flex-1 items-start md:grid md:grid-cols-[220px_minmax(0,1fr)] md:gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-10') do
							render Shared::Sidebar.new
							main(class: 'relative py-6 lg:gap-10 lg:py-8 xl:grid xl:grid-cols-[1fr_300px]', &block)
						end
					end
				end
			end
		end
	end
end
