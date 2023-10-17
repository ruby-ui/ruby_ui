# frozen_string_literal: true

class ApplicationLayout < ApplicationView
	include Phlex::Rails::Layout

	def template(&block)
		doctype

		html do
			head do
				title { "PhlexUI - Component Library" }
				meta name: "viewport", content: "width=device-width,initial-scale=1"
				csp_meta_tag
				csrf_meta_tags
				stylesheet_link_tag "https://api.fontshare.com/v2/css?f[]=general-sans@701,200,500,301,201,300,601,600,401,501,400,700&display=swap", data_turbo_track: "reload"
				stylesheet_link_tag "application", data_turbo_track: "reload"
				javascript_include_tag "application", data_turbo_track: "reload", defer: true
			end

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
