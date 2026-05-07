# frozen_string_literal: true

module Docs
  class ComponentsTable < Phlex::HTML
    def initialize(files)
      @files = files
    end

    def view_template
      # Minimal stub - empty by default
    end
  end
end
