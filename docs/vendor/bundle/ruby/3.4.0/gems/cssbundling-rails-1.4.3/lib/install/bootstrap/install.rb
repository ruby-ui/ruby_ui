require_relative "../helpers"
self.extend Helpers

apply "#{__dir__}/../install.rb"

say "Install Bootstrap with Bootstrap Icons, Popperjs/core and Autoprefixer"
copy_file "#{__dir__}/application.bootstrap.scss",
   "app/assets/stylesheets/application.bootstrap.scss"
run "#{bundler_cmd} add sass bootstrap bootstrap-icons @popperjs/core postcss postcss-cli autoprefixer nodemon"

inject_into_file "config/initializers/assets.rb", after: /.*Rails.application.config.assets.paths.*\n/ do
  <<~RUBY
    Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap-icons/font")
  RUBY
end

if Rails.root.join("app/javascript/application.js").exist?
  say "Appending Bootstrap JavaScript import to default entry point"
  append_to_file "app/javascript/application.js", %(import * as bootstrap from "bootstrap"\n)
else
  say %(Add import * as bootstrap from "bootstrap" to your entry point JavaScript file), :red
end

if Rails.root.join("config/importmap.rb").exist?
  say "Pin Bootstrap"
  append_to_file "config/importmap.rb", %(pin "bootstrap", to: "bootstrap.bundle.min.js"\n)

  inject_into_file "config/initializers/assets.rb", after: /.*\/bootstrap-icons\/font.*\n/ do
    <<~RUBY
      Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap/dist/js")
    RUBY
  end

  append_to_file "config/initializers/assets.rb", %(Rails.application.config.assets.precompile << "bootstrap.bundle.min.js")
end

add_package_json_script("build:css:compile", "sass ./app/assets/stylesheets/application.bootstrap.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules")
add_package_json_script("build:css:prefix", "postcss ./app/assets/builds/application.css --use=autoprefixer --output=./app/assets/builds/application.css")
add_package_json_script("build:css", "#{bundler_run_cmd} build:css:compile && #{bundler_run_cmd} build:css:prefix")
add_package_json_script("watch:css", "nodemon --watch ./app/assets/stylesheets/ --ext scss --exec \\\"#{bundler_run_cmd} build:css\\\"", false)

gsub_file "Procfile.dev", "build:css --watch", "watch:css"

package_json = JSON.parse(File.read("package.json"))
package_json["browserslist"] ||= {}
package_json["browserslist"] = ["defaults"]
File.write("package.json", JSON.pretty_generate(package_json))
