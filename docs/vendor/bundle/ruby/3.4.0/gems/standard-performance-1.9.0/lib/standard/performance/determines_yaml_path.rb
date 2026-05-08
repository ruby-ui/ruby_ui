module Standard
  module Performance
    class DeterminesYamlPath
      def determine(desired_version)
        desired_version = Gem::Version.new(desired_version) unless desired_version.is_a?(Gem::Version)
        default = "base.yml"

        file_name = if !Gem::Version.correct?(desired_version)
          default
        elsif desired_version < Gem::Version.new("1.9")
          "ruby-1.8.yml"
        elsif desired_version < Gem::Version.new("2.0")
          "ruby-1.9.yml"
        elsif desired_version < Gem::Version.new("2.1")
          "ruby-2.0.yml"
        elsif desired_version < Gem::Version.new("2.2")
          "ruby-2.1.yml"
        elsif desired_version < Gem::Version.new("2.3")
          "ruby-2.2.yml"
        else
          default
        end

        Pathname.new(__dir__).join("../../../config/#{file_name}")
      end
    end
  end
end
