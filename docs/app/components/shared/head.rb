# frozen_string_literal: true

module Components
  module Shared
    class Head < Components::Base
      include Phlex::Rails::Layout

      def view_template
        head do
          title { "RubyUI - Component Library" }
          meta name: "viewport", content: "width=device-width,initial-scale=1"
          meta name: "turbo-refresh-method", content: "morph"
          meta name: "turbo-refresh-scroll", content: "preserve"
          meta name: "view-transition", content: "same-origin"

          link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png"
          link rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png"
          link rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png"
          link rel: "manifest", href: "/site.webmanifest"

          csp_meta_tag
          csrf_meta_tags
          stylesheet_link_tag "https://api.fontshare.com/v2/css?f[]=general-sans@1&display=swap", data_turbo_track: "reload"
          stylesheet_link_tag "application", data_turbo_track: "reload"
          javascript_include_tag "application", data_turbo_track: "reload", type: "module"
        end
      end
    end
  end
end
