# frozen_string_literal: true

require "rouge"

module RubyUI
  # A block of code, styled after shadcn's CodeBlock (Base UI + vega).
  #
  # Shorthand: Codeblock(code, syntax: :ruby) renders the code highlighted by
  # Rouge with a copy button in the top-right corner (clipboard: false drops
  # it). Without code it is the root of a composition: CodeblockHeader,
  # CodeblockTitle, CodeblockActions, CodeblockCopyButton, CodeblockContent,
  # CodeblockLine and CodeblockFooter.
  #
  # Syntax colors come from CodeblockTheme, rendered once in the <head>.
  class Codeblock < Base
    VARIANTS = {
      default: "border border-input text-foreground dark:bg-input/30 " \
        "has-[>[data-slot=code-block-content]:focus-visible]:border-ring",
      destructive: "border border-destructive/30 text-destructive dark:border-destructive/40"
    }.freeze

    SIZES = %i[default sm].freeze

    def initialize(code = nil, syntax: nil, variant: :default, size: :default, clipboard: true,
      clipboard_success: "Copied", clipboard_error: "Copy failed", wrap: false, line_numbers: false,
      start_line: 1, **attrs)
      @code = code
      @syntax = syntax
      @variant = variant.to_s.to_sym
      @variant = :default unless VARIANTS.key?(@variant)
      @size = size.to_s.to_sym
      @size = :default unless SIZES.include?(@size)
      @clipboard = clipboard
      @clipboard_success = clipboard_success
      @clipboard_error = clipboard_error
      @content = {wrap: wrap, line_numbers: line_numbers, start_line: start_line}
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        @code.nil? ? block&.call : shorthand
      end
    end

    private

    def shorthand
      if @clipboard
        render CodeblockActions.new do
          render CodeblockCopyButton.new(value: @code, copied_label: @clipboard_success, error_label: @clipboard_error)
        end
      end
      render CodeblockContent.new(@code, syntax: @syntax, **@content)
    end

    def default_attrs
      {
        data: {slot: "code-block", variant: @variant, size: @size, controller: "ruby-ui--codeblock"},
        class: [
          "group/code-block relative flex w-full min-w-0 flex-col overflow-hidden rounded-lg text-sm data-[size=sm]:text-xs",
          "has-[>[data-slot=code-block-content]:focus-visible]:ring-3 has-[>[data-slot=code-block-content]:focus-visible]:ring-ring/50",
          VARIANTS.fetch(@variant)
        ]
      }
    end
  end
end
