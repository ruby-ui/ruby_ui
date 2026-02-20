module RubyUI
  module Generators
    module JavascriptUtils
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
        when "tippy.js"
          pin_tippy_js
        else
          run "bin/importmap pin #{package}"
        end
      end

      def using_importmap?
        File.exist?(Rails.root.join("config/importmap.rb")) && File.exist?(Rails.root.join("bin/importmap"))
      end

      def using_bun? = File.exist?(Rails.root.join("bun.lock"))

      def using_npm? = File.exist?(Rails.root.join("package-lock.json"))

      def using_pnpm? = File.exist?(Rails.root.join("pnpm-lock.yaml"))

      def using_yarn? = File.exist?(Rails.root.join("yarn.lock"))

      def pin_motion
        say <<~TEXT
          WARNING: Installing motion from CDN because `bin/importmap pin motion` doesn't download the correct file.
        TEXT

        inject_into_file Rails.root.join("config/importmap.rb"), <<~RUBY
          pin "motion", to: "https://cdn.jsdelivr.net/npm/motion@11.11.17/+esm"\n
        RUBY
      end

      def pin_tippy_js
        say <<~TEXT
          WARNING: Installing tippy.js from CDN because `bin/importmap pin tippy.js` doesn't download the correct file.
        TEXT

        inject_into_file Rails.root.join("config/importmap.rb"), <<~RUBY
          pin "tippy.js", to: "https://cdn.jsdelivr.net/npm/tippy.js@6.3.7/+esm"
          pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/+esm"\n
        RUBY
      end
    end
  end
end
