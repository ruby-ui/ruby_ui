# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "pathname"
require "tmpdir"
require_relative "../../lib/generators/ruby_ui/javascript_utils"

class JavascriptUtilsTest < Minitest::Test
  class FakeInstaller
    include RubyUI::Generators::JavascriptUtils

    attr_reader :download_source, :download_destination

    def initialize(root)
      @root = Pathname.new(root)
    end

    def say(*) = nil

    def empty_directory(path)
      FileUtils.mkdir_p(path)
    end

    def get(source, destination)
      @download_source = source
      @download_destination = destination
      FileUtils.touch(destination)
    end

    def rails_root = @root
  end

  def test_tw_animate_css_is_downloaded_as_css_asset_for_importmap
    Dir.mktmpdir do |root|
      installer = FakeInstaller.new(root)

      installer.pin_with_importmap("tw-animate-css")

      assert_equal "https://cdn.jsdelivr.net/npm/tw-animate-css@1.4.0/dist/tw-animate.css", installer.download_source
      assert_equal Pathname.new(root).join("vendor/javascript/tw-animate-css.css"), installer.download_destination
      assert File.exist?(installer.download_destination)
    end
  end
end
