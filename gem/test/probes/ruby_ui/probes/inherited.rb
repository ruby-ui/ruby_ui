# frozen_string_literal: true

module RubyUI
  module Probes
    # No sidecar of its own: renders Div's, as a host subclass of a gem
    # component does (decision 13).
    class Inherited < Div
    end
  end
end
