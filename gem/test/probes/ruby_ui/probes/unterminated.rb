# frozen_string_literal: true

module RubyUI
  module Probes
    # Its sidecar has no final newline — the one branch of render_in's
    # newline drop that every other probe leaves unexercised.
    class Unterminated < Component
    end
  end
end
