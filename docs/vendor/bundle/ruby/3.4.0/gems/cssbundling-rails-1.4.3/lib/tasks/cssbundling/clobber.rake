namespace :css do
  desc "Remove CSS builds"
  task :clobber do
    rm_rf Dir["app/assets/builds/**/[^.]*.{css,css.map}"], verbose: false
  end
end

if Rake::Task.task_defined?("assets:clobber")
  Rake::Task["assets:clobber"].enhance(["css:clobber"])
end
