module RubyUI
  module Generators
    module JavascriptUtils
      def install_js_package(package)
        if using_importmap?
          pin_with_importmap(package)
        elsif using_yarn?
          run "yarn add #{package}"
        elsif using_npm?
          run "npm install #{package}"
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

      def using_npm? = File.exist?(Rails.root.join("package-lock.json"))

      def using_yarn? = File.exist?(Rails.root.join("yarn.lock"))
    end
  end
end
