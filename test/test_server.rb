require "sinatra"
require "phlex"
require_relative "../lib/ruby_ui"

def copy_dist_to_public_js
  dist_dir = File.expand_path("../../dist", __FILE__)
  public_js_dir = File.join(settings.public_folder, "js")

  # Create the public/js directory if it doesn't exist
  FileUtils.mkdir_p(public_js_dir) unless File.directory?(public_js_dir)

  if File.directory?(dist_dir)
    # Copy all files from dist to public/js
    FileUtils.cp_r(File.join(dist_dir, "."), public_js_dir)
    puts "Copied all files from dist to public/js directory"
  else
    puts "Warning: dist directory not found"
  end
end

copy_dist_to_public_js

class TestContext < Phlex::HTML
  def view_template(&)
    doctype

    html do
      head do
        script src: "https://unpkg.com/@hotwired/stimulus/dist/stimulus.umd.js"
        script src: "https://cdn.tailwindcss.com"
        # script src: "https://cdn.jsdelivr.net/npm/tailwindcss-animate@1.0.7/index.js"
        script src: "/js/ruby_ui_js.min.js"
        link rel: "stylesheet", href: "/css/main.css", as: "style"
        script src: "/js/main.js", type: "module"
      end
      body do
        div(&)
      end
    end
  end
end

def phlex_context(&)
  TestContext.new.call(&)
end

# Load all your components
# Dir["#{File.dirname(__FILE__)}/ruby_ui/*/*_spec.rb"].each { |file| require file }
# Dir["#{File.dirname(__FILE__)}/ruby_ui/*/*_spec.rb"].each do |file|
#   require File
# end

require_relative "ruby_ui/alert_dialog/alert_dialog_spec"
# binding.irb
# Set up Sinatra
set :public_folder, File.dirname(__FILE__) + "/public"
set :views, File.dirname(__FILE__) + "/views"

# Define routes to render your components
get "/" do
  erb :index
end

get "/component/alert_dialog" do
  phlex_context do
    RubyUI::AlertDialogSpec.new.spec(self)
  end
end

get "/component/:name" do
  component_name = params[:name].capitalize
  component_class = Object.const_get("RubyUI::#{component_name}")
  component = component_class.new
  component.call
end

# Add more routes as needed for different components or scenarios
