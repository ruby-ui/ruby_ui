# frozen_string_literal: true

require "tailwind_merge"

module RubyUI
  class Base < Phlex::HTML
    TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

    attr_reader :attrs

    def initialize(**user_attrs)
      @attrs = mix(default_attrs, user_attrs)
      @attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class]) if @attrs[:class]
    end

    if defined?(Rails) && Rails.env.development?
      def before_template
        comment { "Before #{self.class.name}" }
        super
      end
    end

    private

    def all_template_tag(**attrs, &)
      current_version = Gem.loaded_specs["phlex"].version
      if current_version.segments[0] >= 2
        template(**attrs, &)
      else
        template_tag(**attrs, &)
      end
    end

    def default_attrs
      {}
    end
  end
end
