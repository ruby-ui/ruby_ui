# frozen_string_literal: true

class Alert < ApplicationComponent
  def initialize(variant: nil)
    @variant = variant
  end

  def template(&)
    case @variant
    when nil
      div(class: 'relative w-full rounded-lg border px-4 py-3 text-sm [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground [&>svg~*]:pl-7 bg-background text-foreground', &)
    when :destructive
      div(class: 'relative w-full rounded-lg border px-4 py-3 text-sm [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg~*]:pl-7 border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive', &)
    end
  end
end
