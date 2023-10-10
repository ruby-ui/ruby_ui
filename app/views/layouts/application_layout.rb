# frozen_string_literal: true

class ApplicationLayout < ApplicationView
	include Phlex::Rails::Layout

	def template(&block)
		doctype

		html do
			head do
				title { "Phlex Components Library" }
				meta name: "viewport", content: "width=device-width,initial-scale=1"
				csp_meta_tag
				csrf_meta_tags
				stylesheet_link_tag "https://api.fontshare.com/v2/css?f[]=satoshi@900,700,500,301,701,300,501,401,901,400&display=swap", data_turbo_track: "reload"
				stylesheet_link_tag "application", data_turbo_track: "reload"
				javascript_include_tag "application", data_turbo_track: "reload", defer: true
			end

			body do
				main(&block)
			end
		end
	end
end
