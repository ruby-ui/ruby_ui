# frozen_string_literal: true

module RubyUI
  # The 2.0 component layer: a plain Ruby object that ActionView renders through
  # `render_in`, with an ERB sidecar template next to the class file.
  #
  #   # app/components/ruby_ui/dialog/dialog.rb
  #   class RubyUI::Dialog < RubyUI::Base
  #     def initialize(open: false, **attrs)
  #       @open = open
  #       super(**attrs)
  #     end
  #
  #     private def default_attrs
  #       {data: {controller: "ruby-ui--dialog", ruby_ui__dialog_open_value: @open}}
  #     end
  #   end
  #
  #   # app/components/ruby_ui/dialog/dialog.html.erb
  #   <div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
  #
  #   # a view
  #   <%= render RubyUI::Dialog.new(open: true) do %> ... <% end %>
  #
  # `attrs` is computed in `initialize` with no view context — mix, Tailwind
  # merge, then Phlex-semantics serialization (see Attributes) — so a component
  # can read a neighbour's computed attributes (`Button.new(...).attrs["class"]`).
  # `render_in` captures the caller's block with the component as the block
  # argument (for `do |group|` components), then renders the sidecar template
  # with `component` as its only local. Nothing else: no named slots, no DSL.
  class Base
    attr_reader :attrs, :content

    def initialize(**user_attrs)
      mixed = Attributes.mix(default_attrs, user_attrs)
      mixed[:class] = Attributes.merge_classes(mixed[:class]) if mixed[:class]
      @attrs = Attributes.flat(mixed)
    end

    # ActionView's renderable protocol: `render RubyUI::X.new(...) do ... end`.
    # The pinned Rails ref passes `locals:` and deprecates the 1-arity form; the
    # caller's locals are not the component's, so they are accepted and ignored.
    def render_in(view_context, **, &block)
      @view_context = view_context
      @content = view_context.capture(self, &block) if block
      view_context.render(template: self.class.template_path(view_context.lookup_context.view_paths),
        locals: {component: self})
    end

    # The view context, for a component that needs a Rails helper from Ruby
    # (`helpers.form_authenticity_token`) or renders a neighbour from a method
    # (`ToggleGroup#ToggleGroupItem`). Only available during render_in.
    def helpers
      @view_context or raise ArgumentError, "#{self.class.name} has no view context outside render_in"
    end

    # The sidecar template is the class file with `.rb` dropped, resolved
    # relative to whichever configured view path contains it. That view path is
    # the install step: `prepend_view_path` on the directory holding ruby_ui/.
    def self.template_path(view_paths)
      @template_path ||= begin
        file = Object.const_source_location(name)&.first
        raise ArgumentError, "#{name}: no source location to derive a sidecar template from" unless file

        roots = view_paths.paths.filter_map { |resolver| resolver.path.to_s if resolver.respond_to?(:path) }
        root = roots.find { |dir| file.start_with?("#{dir}/") }
        raise ArgumentError, "#{name}: #{file} is under no view path; prepend_view_path the directory that holds ruby_ui/" unless root

        file.delete_prefix("#{root}/").delete_suffix(".rb")
      end
    end

    private

    def default_attrs
      {}
    end
  end
end
