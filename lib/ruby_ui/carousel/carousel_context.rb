# frozen_string_literal: true

module RubyUI
  class CarouselContext
    def self.with_context(**state)
      Thread.current[:ruby_ui__carousel_state] = state
      yield
    ensure
      Thread.current[:ruby_ui__carousel_state] = nil
    end

    def self.state
      Thread.current[:ruby_ui__carousel_state] || {}
    end

    def self.orientation
      state[:orientation]
    end
  end
end
