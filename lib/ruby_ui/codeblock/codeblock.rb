# frozen_string_literal: true

require "rouge"

module RubyUI
  class Codeblock
    include ComponentBase

    FORMATTER = ::Rouge::Formatters::HTML.new
    ROUGE_CSS = Rouge::Themes::Github.mode(:dark).render(scope: ".highlight")

    def initialize(code, syntax:, clipboard: true, clipboard_success: "Copied!", clipboard_error: "Copy failed!", **attrs)
      @code = code
      @syntax = syntax.to_sym
      @clipboard = clipboard
      @clipboard_success = clipboard_success
      @clipboard_error = clipboard_error

      if @syntax == :ruby || @syntax == :html
        @code = @code.gsub(/(?:^|\G) {2}/m, "\t")
      end

      super(**attrs)
    end

    def clipboard?
      @clipboard
    end

    attr_reader :syntax

    attr_reader :code

    attr_reader :clipboard_success

    attr_reader :clipboard_error

    def highlighted_code
      FORMATTER.format(lexer.lex(@code))
    end

    def rouge_css
      ROUGE_CSS
    end

    private

    def lexer
      Rouge::Lexer.find(@syntax)
    end

    def default_attrs
      {
        style: {tab_size: 2},
        class: "highlight text-sm max-h-[350px] after:content-none flex font-mono overflow-auto overflow-x rounded-md border !bg-stone-900 [&_pre]:p-4"
      }
    end
  end
end
