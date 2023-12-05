# frozen_string_literal: true

class Shared::Head < ApplicationComponent
    include Phlex::Rails::Layout

    def template
        head do
            title { "PhlexUI - Component Library" }
            meta name: "viewport", content: "width=device-width,initial-scale=1"
            csp_meta_tag
            csrf_meta_tags
            stylesheet_link_tag "https://api.fontshare.com/v2/css?f[]=general-sans@1&display=swap", data_turbo_track: "reload"
            stylesheet_link_tag "application", data_turbo_track: "reload"
            javascript_include_tag "application", data_turbo_track: "reload", defer: true
        end
    end
end
