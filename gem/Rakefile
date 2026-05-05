# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.warning = false
end

require "standard/rake"

task default: %i[test standard]
