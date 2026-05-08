module RubyUI
  module Generators
    module JavascriptUtils
      TW_ANIMATE_CSS_VERSION = "1.4.0"

      def install_js_package(package)
        if using_importmap?
          pin_with_importmap(package)
        elsif using_bun?
          run "bun add #{package}"
        elsif using_yarn?
          run "yarn add #{package}"
        elsif using_npm?
          run "npm install #{package}"
        elsif using_pnpm?
          run "pnpm install #{package}"
        else
          say "Could not detect the package manager, you need to install '#{package}' manually", :red
        end
      end

      def pin_with_importmap(package)
        case package
        when "motion"
          pin_motion
        when "tw-animate-css"
          pin_tw_animate_css
        when "tippy.js"
          pin_tippy_js
        else
          run "bin/importmap pin #{package}"
        end
      end

      def using_importmap?
        File.exist?(rails_root.join("config/importmap.rb")) && File.exist?(rails_root.join("bin/importmap"))
      end

      def using_bun? = File.exist?(rails_root.join("bun.lock"))

      def using_npm? = File.exist?(rails_root.join("package-lock.json"))

      def using_pnpm? = File.exist?(rails_root.join("pnpm-lock.yaml"))

      def using_yarn? = File.exist?(rails_root.join("yarn.lock"))

      def pin_tw_animate_css
        say <<~TEXT
          WARNING: Installing tw-animate-css as a CSS asset because Importmap cannot pin CSS-only package exports.
        TEXT

        empty_directory rails_root.join("vendor/javascript")
        # CDN serves "tw-animate.css"; we save as "tw-animate-css.css" to match package name. Do not "correct" the URL.
        get "https://cdn.jsdelivr.net/npm/tw-animate-css@#{TW_ANIMATE_CSS_VERSION}/dist/tw-animate.css",
          rails_root.join("vendor/javascript/tw-animate-css.css")
      end

      def pin_motion
        say <<~TEXT
          WARNING: Installing motion from CDN because `bin/importmap pin motion` doesn't download the correct file.
        TEXT

        inject_into_file rails_root.join("config/importmap.rb"), <<~RUBY
          pin "motion", to: "https://cdn.jsdelivr.net/npm/motion@11.11.17/+esm"\n
        RUBY
      end

      def pin_tippy_js
        say <<~TEXT
          WARNING: Installing tippy.js from CDN because `bin/importmap pin tippy.js` doesn't download the correct file.
        TEXT

        inject_into_file rails_root.join("config/importmap.rb"), <<~RUBY
          pin "tippy.js", to: "https://cdn.jsdelivr.net/npm/tippy.js@6.3.7/+esm"
          pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/+esm"\n
        RUBY
      end

      def rails_root = Rails.root
    end
  end
end
