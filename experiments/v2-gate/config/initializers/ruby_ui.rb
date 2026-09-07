# Wiring for the 2.0 component layer (app/components/ruby_ui/).
#
# The first two lines are what the 1.6 installer already writes
# (gem/lib/generators/ruby_ui/install/templates/ruby_ui.rb.erb): the RubyUI
# acronym for Zeitwerk, and one namespace per component directory so
# app/components/ruby_ui/dialog/dialog_content.rb defines RubyUI::DialogContent.
Rails.autoloaders.main.inflector.inflect("ruby_ui" => "RubyUI")
Rails.autoloaders.main.collapse(Rails.root.join("app/components/ruby_ui/*"))

# The one line 2.0 adds. The directory that holds ruby_ui/ becomes a view path,
# so a component's sidecar template resolves as `ruby_ui/<dir>/<name>` and
# RubyUI::Base#render_in can render it with `render template:`.
# Same hook Rails' own add_view_paths initializer uses; registered later, it
# runs later, so app/components ends up ahead of app/views and engine views.
ActiveSupport.on_load(:action_controller) do
  prepend_view_path Rails.root.join("app/components") if respond_to?(:prepend_view_path)
end
