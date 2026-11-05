# frozen_string_literal: true

require "rouge"

module RubyUI
  # The scrollable code: a focusable <pre> (so the keyboard can scroll it)
  # with a <code> inside.
  #
  # Given code, it highlights it with Rouge (syntax: any Rouge lexer name;
  # plain text without it) and, with line_numbers: true, renders one
  # CodeblockLine per line, numbered from start_line. Without code, the block
  # gives its own content, usually CodeblockLines (e.g. a diff with
  # variant: :added / :removed). wrap: true wraps long lines instead of
  # scrolling sideways.
  class CodeblockContent < Base
    FORMATTER = ::Rouge::Formatters::HTML.new

    def initialize(code = nil, syntax: nil, wrap: false, line_numbers: false, start_line: 1, style: nil, **attrs)
      @code = code
      @style = style
      @syntax = syntax
      @wrap = wrap
      @line_numbers = line_numbers
      @start_line = start_line.to_i
      super(**attrs)
    end

    def view_template(&block)
      pre(**attrs) do
        code(
          data: {slot: "code-block-code"},
          class: "grid min-h-lh min-w-max content-start in-data-numbered:grid-cols-[auto_1fr] in-data-wrap:min-w-0"
        ) do
          if @code.nil?
            block&.call
          elsif @line_numbers
            lines.each { |line| render CodeblockLine.new { raw(safe(line)) } }
          else
            # One grid item: Rouge's spans would each take a row of the grid.
            span { raw(safe(FORMATTER.format(lexer.lex(@code)))) }
          end
        end
      end
    end

    private

    def lexer
      (@syntax && ::Rouge::Lexer.find(@syntax.to_s)) || ::Rouge::Lexers::PlainText
    end

    # Highlighted HTML per line, without the trailing newline, so each line's
    # spans close inside its CodeblockLine.
    def lines
      lines = [[]]
      lexer.lex(@code.chomp).each do |token, value|
        value.split(/(\n)/).each do |part|
          if part == "\n"
            lines << []
          elsif !part.empty?
            lines.last << [token, part]
          end
        end
      end
      lines.map { |tokens| FORMATTER.format(tokens) }
    end

    # One declaration list: Phlex's mix would join our string with the
    # caller's style without a separator. The caller's style comes last, so it
    # wins, as in shadcn ({counterReset, ...style}).
    def style
      own = "counter-reset: line #{@start_line - 1};"
      theirs = @style.is_a?(Hash) ? @style.map { |k, v| "#{k.to_s.tr("_", "-")}: #{v};" }.join(" ") : @style.to_s.strip
      theirs = "#{theirs};" unless theirs.empty? || theirs.end_with?(";")
      [own, theirs].reject(&:empty?).join(" ")
    end

    def default_attrs
      data = {slot: "code-block-content"}
      data[:wrap] = true if @wrap
      data[:numbered] = true if @line_numbers
      {
        dir: "ltr",
        tabindex: 0,
        style: style,
        data: data,
        class: [
          "min-h-0 min-w-0 scroll-fade-x scrollbar-thin overflow-auto px-4 py-4 text-start font-mono leading-relaxed outline-none",
          "data-wrap:scroll-fade-y data-wrap:wrap-break-word data-wrap:whitespace-pre-wrap",
          "group-has-data-[slot=code-block-header]/code-block:pt-2 group-has-data-[slot=code-block-footer]/code-block:pb-2",
          "group-data-[size=sm]/code-block:px-3 group-data-[size=sm]/code-block:py-3",
          "group-data-[size=sm]/code-block:group-has-data-[slot=code-block-header]/code-block:pt-1.5"
        ]
      }
    end
  end
end
