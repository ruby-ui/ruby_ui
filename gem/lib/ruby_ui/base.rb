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

    private

    def default_attrs
      {}
    end
  end
end
