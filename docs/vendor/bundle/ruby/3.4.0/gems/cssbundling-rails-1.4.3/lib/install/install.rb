require_relative "helpers"
self.extend Helpers

say "Build into app/assets/builds"
empty_directory "app/assets/builds"
keep_file "app/assets/builds"

if (sprockets_manifest_path = Rails.root.join("app/assets/config/manifest.js")).exist?
  append_to_file sprockets_manifest_path, %(//= link_tree ../builds\n)

  say "Stop linking stylesheets automatically"
  gsub_file "app/assets/config/manifest.js", "//= link_directory ../stylesheets .css\n", ""
end

if Rails.root.join(".gitignore").exist?
  append_to_file(".gitignore", %(\n/app/assets/builds/*\n!/app/assets/builds/.keep\n))
  append_to_file(".gitignore", %(\n/node_modules\n))
end

say "Remove app/assets/stylesheets/application.css so build output can take over"
remove_file "app/assets/stylesheets/application.css"

if Rails::VERSION::MAJOR < 8
  if (app_layout_path = Rails.root.join("app/views/layouts/application.html.erb")).exist?
    say "Add stylesheet link tag in application layout"
    insert_into_file(
      app_layout_path.to_s,
      defined?(Turbo) ?
        %(\n    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>) :
        %(\n    <%= stylesheet_link_tag "application" %>),
      before: /\s*<\/head>/
    )
  else
    say "Default application.html.erb is missing!", :red
    if defined?(Turbo)
      say %(        Add <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %> within the <head> tag in your custom layout.)
    else
      say %(        Add <%= stylesheet_link_tag "application" %> within the <head> tag in your custom layout.)
    end
  end
end

unless Rails.root.join("package.json").exist?
  say "Add default package.json"
  copy_file "#{__dir__}/package.json", "package.json"
end

if Rails.root.join("Procfile.dev").exist?
  append_to_file "Procfile.dev", "css: #{bundler_run_cmd} build:css --watch\n"
else
  say "Add default Procfile.dev"
  copy_file "#{__dir__}/#{using_bun? ? "Procfile_for_bun.dev" : "Procfile_for_node.dev"}", "Procfile.dev"

  say "Ensure foreman is installed"
  run "gem install foreman"
end

say "Add bin/dev to start foreman"
copy_file "#{__dir__}/dev", "bin/dev", force: true
chmod "bin/dev", 0755, verbose: false
