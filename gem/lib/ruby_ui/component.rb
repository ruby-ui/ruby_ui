# frozen_string_literal: true

require "action_view"
require_relative "attributes"

module RubyUI
  class << self
    # The directories that hold `ruby_ui/`: `app/components` in a host
    # application, `lib` in this gem. A component's sidecar template is looked
    # up under the root that contains its class file, and nowhere else — the
    # application's view paths are never consulted, so a host template at the
    # same virtual path cannot shadow it and it cannot shadow the host.
    def component_roots
      @component_roots ||= []
    end

    attr_writer :component_roots

    def lookup_for(root)
      (@lookups ||= {})[root] ||= ActionView::LookupContext.new(
        ActionView::PathRegistry.cast_file_system_resolvers([root]), {formats: [:html]}
      )
    end
  end

  # The 2.0 component layer: a plain Ruby object that ActionView renders
  # through `render_in`, with an ERB sidecar template next to the class file.
  #
  #   # app/components/ruby_ui/dialog/dialog.rb
  #   class RubyUI::Dialog < RubyUI::Component
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
  # `mixed_attrs` is the same hash before serialization — nested, Symbol-keyed,
  # classes merged; what `attrs` was in 1.6 — for a component that forwards its
  # attributes to another component in Ruby (`Checkbox.new(**mixed_attrs)`) or
  # merges more in before serializing (`Attributes.flat({type: "button"}.merge(mixed_attrs))`).
  # Forwarding the flat form instead puts `"data-action"` beside the neighbour's
  # `data: {action:}` and two attributes reach the page (decision 11).
  #
  # `render_in` captures the caller's block with the component as the block
  # argument (for `do |group|` components), renders the sidecar with
  # `component` as its only local, and drops the sidecar file's final newline
  # when the file has one: 1.6 emitted none, and inside a parent it would be a
  # text node after the component (decision 12). A class with no sidecar beside its own file
  # renders its nearest ancestor's, as a host's `class MyButton < RubyUI::Button`
  # inherited `view_template` in 1.6 (decision 13). Nothing else: no named
  # slots, no DSL.
  #
  # Named `Component` while the Phlex `RubyUI::Base` still exists; it takes
  # the name `Base` when the last Phlex component is gone.
  class Component
    attr_reader :attrs, :mixed_attrs, :content

    def initialize(**user_attrs)
      mixed = Attributes.mix(default_attrs, user_attrs)
      mixed[:class] = Attributes.merge_classes(mixed[:class]) if mixed[:class]
      @mixed_attrs = mixed.freeze
      @attrs = Attributes.flat(mixed)
    end

    # ActionView's renderable protocol. Rails passes `locals:`; the caller's
    # locals are not the component's, so they are accepted and ignored.
    # `content` is set on every call — nil without a block — so an instance
    # rendered twice never repeats its first content.
    def render_in(view_context, **, &block)
      @view_context = view_context
      @content = block ? view_context.capture(self, &block) : nil
      template = self.class.template
      rendered = template.render(view_context, {component: self})
      # The file's final newline, when the file has one; a sidecar never
      # carries a trim marker (decision 12), so the last byte of the source
      # is the last byte of the output.
      (template.source.end_with?("\n") && rendered.end_with?("\n")) ? rendered.chomp.html_safe : rendered
    end

    # The view context, for a component that needs a Rails helper from Ruby
    # (`helpers.form_authenticity_token`) or renders a neighbour from a method.
    # Set by render_in; raises before the first render.
    def helpers
      @view_context or raise ArgumentError, "#{self.class.name} has no view context outside render_in"
    end

    class << self
      # Looked up on every render, not cached here: the resolver behind the
      # lookup context caches compiled templates and Rails' reloader clears it,
      # so a Template cached on the class would outlive an edit in development.
      # The class's own sidecar, or the nearest ancestor's up to Component.
      def template
        klass = self
        reasons = []
        while klass < Component
          found, reason = klass.own_template
          return found if found

          reasons << reason
          klass = klass.superclass
        end
        raise ArgumentError, "#{name} has no sidecar template: #{reasons.join("; ")}"
      end

      # [template, nil] when a sidecar sits beside this class's own file under a
      # component root; [nil, why not] otherwise. `exists?` before `find`, so an
      # inherited sidecar costs no exception per render.
      def own_template
        root = component_root
        return [nil, "#{source_file} is under none of RubyUI.component_roots #{RubyUI.component_roots.inspect}"] unless root

        relative = source_file.delete_prefix("#{root}/").delete_suffix(".rb")
        prefix, base = File.split(relative)
        # A file directly under the root splits to ".", which the lookup
        # does not resolve; the empty prefix list does.
        prefixes = (prefix == ".") ? [] : [prefix]
        lookup = RubyUI.lookup_for(root)
        return [nil, "no #{relative}.html.erb under #{root}"] unless lookup.exists?(base, prefixes, false, [:component])

        [lookup.find(base, prefixes, false, [:component]), nil]
      end

      def source_file
        @source_file ||= Object.const_source_location(name)&.first or
          raise ArgumentError, "#{name}: no source location to derive a sidecar template from"
      end

      # Memoized on first use: set RubyUI.component_roots in an initializer,
      # before any render. nil when the file is under no root.
      def component_root
        @component_root ||= RubyUI.component_roots.map(&:to_s).find { |root| source_file.start_with?("#{root}/") }
      end
    end

    private

    def default_attrs
      {}
    end

    # Coerces and validates an enumerated attribute. `size: "lg"` from a tag or
    # from params arrives as a String, `size: :lg` from Ruby as a Symbol, and
    # both must select `table[:lg]`; nil takes the default. Anything else names
    # the allowed values instead of silently dropping the class.
    def enum(value, table, default:)
      key = value.nil? ? default : value
      key = key.to_sym if key.respond_to?(:to_sym)
      return key if table.key?(key)

      if value.nil?
        raise ArgumentError,
          "#{self.class.name}: default: #{default.inspect} is not one of #{table.keys.map(&:inspect).join(", ")}"
      end

      raise ArgumentError,
        "#{self.class.name}: #{value.inspect} is not one of #{table.keys.map(&:inspect).join(", ")}"
    end
  end
end
