# frozen_string_literal: true

require "fileutils"
require "pathname"

namespace :ruby_ui do
  desc "Ensure docs/app/javascript/controllers/ruby_ui/ has a symlink for every gem Stimulus controller"
  task sync_controller_symlinks: :environment do
    gem_root = Rails.root.join("..", "gem", "lib", "ruby_ui")
    controllers_dir = Rails.root.join("app", "javascript", "controllers", "ruby_ui")
    FileUtils.mkdir_p(controllers_dir)

    controller_files = Dir.glob(gem_root.join("**", "*_controller.js")).sort
    if controller_files.empty?
      abort "No *_controller.js files found under #{gem_root} - is the gem/ checkout present?"
    end

    controller_files.each do |gem_path|
      gem_path = Pathname.new(gem_path)
      link_path = controllers_dir.join(gem_path.basename)
      target = gem_path.relative_path_from(controllers_dir)

      if link_path.symlink? && link_path.readlink == target
        puts "ok      #{link_path.basename}"
        next
      end

      link_path.delete if link_path.exist? || link_path.symlink?
      FileUtils.ln_s(target, link_path)
      puts "linked  #{link_path.basename} -> #{target}"
    end

    stale = Dir.glob(controllers_dir.join("*_controller.js")).map { |p| Pathname.new(p).basename.to_s } -
      controller_files.map { |p| Pathname.new(p).basename.to_s }
    stale.each do |basename|
      puts "warning #{basename} has no matching gem controller anymore (not removed automatically)"
    end

    puts "Done. Remember to run `bin/rails stimulus:manifest:update` after adding a brand-new controller."
  end
end
