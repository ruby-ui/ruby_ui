# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |task|
  task.pattern = 'test/**/test_*.rb'
end

RuboCop::RakeTask.new
