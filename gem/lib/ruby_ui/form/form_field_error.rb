# frozen_string_literal: true

module RubyUI
  class FormFieldError < Base
    # errors: strings or objects responding to #message (ActiveModel::Error),
    # e.g. user.errors[:email] or user.errors.where(:email). A block wins over
    # errors. The div is rendered even when empty: the FormField controller
    # writes client-side errors into it, and `empty:hidden` hides it meanwhile.
    def initialize(errors: nil, **user_attrs)
      @messages = Array(errors).map { |error| error.respond_to?(:message) ? error.message : error.to_s }
        .reject { |message| message.strip.empty? }
        .uniq

      super(**user_attrs)
    end

    def view_template(&block)
      div(**attrs) do
        if block
          yield
        elsif @messages.one?
          plain @messages.first
        elsif @messages.any?
          ul(class: "ml-4 flex list-disc flex-col gap-1") do
            @messages.each { |message| li { message } }
          end
        end
      end
    end

    private

    def default_attrs
      {
        role: "alert",
        data: {
          slot: "field-error",
          ruby_ui__form_field_target: "error"
        },
        class: "empty:hidden text-sm font-normal text-destructive"
      }
    end
  end
end
