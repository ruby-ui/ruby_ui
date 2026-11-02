# frozen_string_literal: true

require "rouge"

module RubyUI
  # Syntax colors for every Codeblock: Rouge's GitHub theme, light by default
  # and dark under .dark. Render it once, in the layout's <head>. Plain text
  # keeps the block's text color (the theme's base color and background are
  # left out).
  class CodeblockTheme < Base
    SCOPE = "[data-slot=code-block-code]"

    def self.rouge_css(mode, scope)
      quoted = Regexp.escape(scope)
      ::Rouge::Themes::Github.mode(mode).render(scope: scope)
        .gsub(/^#{quoted} table[^\n]*\n/, "")
        .sub(/^#{quoted}, #{quoted} \.w \{[^}]*\}\n/, "")
    end

    CSS = [rouge_css(:light, SCOPE), rouge_css(:dark, ".dark #{SCOPE}")].join("\n").freeze

    def view_template
      style(**attrs) { raw(safe(CSS)) }
    end
  end
end
