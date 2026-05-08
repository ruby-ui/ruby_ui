require "rake/clean"
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new("test:unit")

namespace :test do
  desc "Test MiniPortile by compiling examples"
  task :examples do
    Dir.chdir("examples") do
      sh "rake ports:all"
    end
  end
end

task :clean do
  FileUtils.rm_rf ["examples/ports", "examples/tmp"], :verbose => true
end

desc "Run all tests"
task :test => ["test:unit", "test:examples"]

task :default => [:test]
