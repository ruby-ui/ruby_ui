# frozen_string_literal: true

module RubyUI
  # One line of code. Numbered when its CodeblockContent has line_numbers:
  # true. variant: :added / :removed mark a diff (+ / − in the gutter),
  # :highlighted shades the line.
  class CodeblockLine < Base
    VARIANTS = {
      default: nil,
      added: "bg-muted after:content-['+']",
      removed: "bg-destructive/10 after:text-destructive after:content-['−']",
      highlighted: "bg-muted"
    }.freeze

    def initialize(variant: :default, **attrs)
      @variant = variant.to_s.to_sym
      @variant = :default unless VARIANTS.key?(@variant)
      super(**attrs)
    end

    # An empty line holds a newline so copying a selection keeps blank lines.
    def view_template(&block)
      span(**attrs) do
        span(data: {slot: "code-block-line-content"}, class: "min-w-0") do
          content = capture(&block) if block
          content.to_s.empty? ? plain("\n") : raw(safe(content))
        end
      end
    end

    private

    def default_attrs
      {
        data: {slot: "code-block-line", variant: @variant},
        class: [
          "relative -mx-4 block min-h-lh px-4 group-data-[size=sm]/code-block:-mx-3 group-data-[size=sm]/code-block:px-3",
          "after:absolute after:start-1 after:top-0 after:text-muted-foreground after:select-none",
          "in-data-numbered:col-span-2 in-data-numbered:grid in-data-numbered:grid-cols-subgrid in-data-numbered:gap-x-3 in-data-numbered:[counter-increment:line]",
          "before:min-w-6 before:text-end before:text-muted-foreground",
          "in-data-numbered:before:content-[counter(line)] in-data-numbered:before:select-none",
          "in-data-numbered:supports-[content:counter(line)_/_'']:before:content-[counter(line)_/_'']",
          VARIANTS.fetch(@variant)
        ]
      }
    end
  end
end
