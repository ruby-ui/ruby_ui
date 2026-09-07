# Spike lane only (Gemfile.tags): Herb `main` component tags.
#
# <RubyUI::Dialog :open="true">…</RubyUI::Dialog> is rewritten at compile time
# by Herb::Engine::ComponentTags::Visitor into
# `render RubyUI::Dialog.new(open: true) do … end`. The visitor rides on Rails'
# own Herb handler at the pinned ref (ActionView::Template::Handlers::ERB::Herb),
# selected through the documented `config.action_view.erb_implementation` — the
# same switch the plan's `core` lane uses — not on ReActionView, whose 0.4.0
# handler targets the 0.10.x engine.
if File.basename(ENV.fetch("BUNDLE_GEMFILE", "")) == "Gemfile.tags"
  require "herb"
  require "herb/engine"
  require "herb/engine/component_tags/visitor"

  class ComponentTagsHerb < ActionView::Template::Handlers::ERB::Herb
    def initialize(input, properties = {})
      properties = Hash[properties]
      properties[:visitors] = Array(properties[:visitors]) + [::Herb::Engine::ComponentTags::Visitor.new]
      super
    end
  end

  Rails.application.config.action_view.erb_implementation = ComponentTagsHerb
end
