require_relative "../helpers"
self.extend Helpers

apply "#{__dir__}/../install.rb"

say "Install Bulma"
copy_file "#{__dir__}/application.bulma.scss",
   "app/assets/stylesheets/application.bulma.scss"
run "#{bundler_cmd} add sass bulma"

say "Add build:css script"
add_package_json_script "build:css",
  "sass ./app/assets/stylesheets/application.bulma.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules"
