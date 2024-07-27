# frozen_string_literal: true

module PhlexUi
  class LinkPreview < Lookbook::Preview
    # Default Link
    # ---------------
    def default
      render(TestView.new) do
        Link(href: "#") { "Link" }
      end
    end

    # Primary Link
    # ---------------
    def primary
      render(TestView.new) do
        Link(href: "#", variant: :primary) { "Primary" }
      end
    end

    # Secondary Link
    # ---------------
    def secondary
      render(TestView.new) do
        Link(href: "#", variant: :secondary) { "Secondary" }
      end
    end

    # Destructive Link
    # ---------------
    def destructive
      render(TestView.new) do
        Link(href: "#", variant: :destructive) { "Destructive" }
      end
    end

    # ghost Link
    # ---------------
    def ghost
      render(TestView.new) do
        Link(href: "#", variant: :ghost) { "Ghost" }
      end
    end
  end
end
