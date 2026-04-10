# frozen_string_literal: true

require "rouge"

module RubyUI
  class Codeblock < Base
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

    def view_template(&)
      style do
        rouge_css
      end

      if clipboard?

        render RubyUI::Clipboard.new(success: clipboard_success, error: clipboard_error, class: "relative") do
          render RubyUI::ClipboardSource.new do
            div(**attrs) do
              div(class: "after:content-none") do
                pre do
                  highlighted_code.html_safe
                end
              end
            end
          end

          div(class: "absolute top-2 right-2") do
            render RubyUI::ClipboardTrigger.new do
              render RubyUI::Button.new(variant: :ghost, size: :sm, icon: true, class: "text-white hover:text-white hover:bg-white/20") do
                svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "w-4 h-4") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M16.5 8.25V6a2.25 2.25 0 00-2.25-2.25H6A2.25 2.25 0 003.75 6v8.25A2.25 2.25 0 006 16.5h2.25m8.25-8.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-7.5A2.25 2.25 0 018.25 18v-1.5m8.25-8.25h-6a2.25 2.25 0 00-2.25 2.25v6")
                end
              end
            end
          end
        end

        div(**attrs) do
          div(class: "after:content-none") do
            pre do
              highlighted_code.html_safe
            end
          end
        end

      end
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
