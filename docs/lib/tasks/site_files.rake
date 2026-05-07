# frozen_string_literal: true

require "fileutils"
require "pathname"

namespace :site_files do
  desc "Generate llms.txt, llms-full.txt, and sitemap.xml"
  task generate: :environment do
    site_files = SiteFiles.new
    output_dir = Pathname.new(ENV.fetch("SITE_FILES_OUTPUT_DIR", Rails.root.join("public").to_s))
    output_dir = Rails.root.join(output_dir) if output_dir.relative?
    files = {
      "llms.txt" => site_files.llms_txt,
      "llms-full.txt" => site_files.llms_full_txt,
      "sitemap.xml" => site_files.sitemap_xml
    }

    FileUtils.mkdir_p(output_dir)

    files.each do |filename, contents|
      path = output_dir.join(filename)
      File.write(path, contents)
      puts "wrote #{path}"
    end
  end
end
