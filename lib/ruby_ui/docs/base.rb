# frozen_string_literal: true

module Views
  class Base < Phlex::HTML
    def Heading(level:, &)
      tag = :"h#{level}"
      send(tag, &)
    end

    def component_files(component_name)
      []
    end

    # Text helper for wrapping paragraphs
    def Text(&)
      p(&)
    end

    # InlineLink helper for documentation links
    def InlineLink(href:, target: nil, class: nil, &)
      a(href: href, target: target, class: binding.local_variable_get(:class), &)
    end

    # Alert component helpers
    def Alert(&)
      div(&)
    end

    def AlertTitle(&)
      h4(&)
    end

    def AlertDescription(&)
      p(&)
    end

    # Route helper stubs - return "#" as placeholder
    def docs_sheet_path
      "#"
    end

    def docs_separator_path
      "#"
    end

    def docs_accordion_path
      "#"
    end

    def docs_alert_path
      "#"
    end

    def docs_alert_dialog_path
      "#"
    end

    def docs_aspect_ratio_path
      "#"
    end

    def docs_avatar_path
      "#"
    end

    def docs_badge_path
      "#"
    end

    def docs_installation_path
      "#"
    end

    # InlineCode helper for typography examples
    def InlineCode(&)
      code(&)
    end
  end
end

# Module-level components stub
module Components
  def self.Heading(level:, &block)
    # Stub for module-level Heading calls
  end

  def self.TypographyList(items:, numbered: false)
    # Stub for TypographyList component
  end
end
