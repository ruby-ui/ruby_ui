namespace :css do
  desc "Install CSS dependencies"
  task :install do
    command = Cssbundling::Tasks.install_command
    unless system(command)
      raise "cssbundling-rails: Command install failed, ensure #{command.split.first} is installed"
    end
  end

  desc "Build your CSS bundle"
  build_task = task :build do
    command = Cssbundling::Tasks.build_command
    unless system(command)
      raise "cssbundling-rails: Command build failed, ensure `#{command}` runs without errors"
    end
  end
  build_task.prereqs << :install unless ENV["SKIP_YARN_INSTALL"] || ENV["SKIP_BUN_INSTALL"]
end

module Cssbundling
  module Tasks
    extend self

    LOCK_FILES = {
      bun: %w[bun.lockb bun.lock yarn.lock],
      yarn: %w[yarn.lock],
      pnpm: %w[pnpm-lock.yaml],
      npm: %w[package-lock.json]
    }

    def install_command
      case
      when using_tool?(:bun) then "bun install"
      when using_tool?(:yarn) then "yarn install"
      when using_tool?(:pnpm) then "pnpm install"
      when using_tool?(:npm) then "npm install"
      else raise "cssbundling-rails: No suitable tool found for installing JavaScript dependencies"
      end
    end

    def build_command
      case
      when using_tool?(:bun) then "bun run build:css"
      when using_tool?(:yarn) then "yarn build:css"
      when using_tool?(:pnpm) then "pnpm build:css"
      when using_tool?(:npm) then "npm run build:css"
      else raise "cssbundling-rails: No suitable tool found for building CSS"
      end
    end

    private

    def tool_exists?(tool)
      system "command -v #{tool} > /dev/null"
    end

    def using_tool?(tool)
      tool_exists?(tool) && LOCK_FILES[tool].any? { |file| File.exist?(file) }
    end
  end
end

unless ENV["SKIP_CSS_BUILD"]
  if Rake::Task.task_defined?("assets:precompile")
    Rake::Task["assets:precompile"].enhance(["css:build"])
  end

  if Rake::Task.task_defined?("test:prepare")
    Rake::Task["test:prepare"].enhance(["css:build"])
  elsif Rake::Task.task_defined?("spec:prepare")
    Rake::Task["spec:prepare"].enhance(["css:build"])
  elsif Rake::Task.task_defined?("db:test:prepare")
    Rake::Task["db:test:prepare"].enhance(["css:build"])
  end
end
