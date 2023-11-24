# frozen_string_literal: true

class Signins::NewView < ApplicationView
    def initialize(redirect_path:)
        @redirect_path = redirect_path
    end

    def template
        render PhlexUI::Card.new(class: 'w-full p-8') do
            render PhlexUI::Form.new(action: helpers.signin_path, method: :post, class: 'w-full') do |f|
                render PhlexUI::Form::Spacer.new do
                    f.input :email, type: "email", placeholder: "Email"
                    render PhlexUI::Button.new(type: "submit", class: "w-full") { "Send sign-in link" }
                end
            end
            render PhlexUI::Typography::Muted.new(class: 'text-muted-foreground text-center mt-4 flex items-center justify-center') do
                sparkle_icon
                span { "We'll send you a magic link to sign in" }
            end
        end
    end

    private

    def sparkle_icon
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            class: "w-3.5 h-3.5 text-amber-500 mr-1.5"
        ) do |s|
            s.path(
                d:
                "M15.98 1.804a1 1 0 00-1.96 0l-.24 1.192a1 1 0 01-.784.785l-1.192.238a1 1 0 000 1.962l1.192.238a1 1 0 01.785.785l.238 1.192a1 1 0 001.962 0l.238-1.192a1 1 0 01.785-.785l1.192-.238a1 1 0 000-1.962l-1.192-.238a1 1 0 01-.785-.785l-.238-1.192zM6.949 5.684a1 1 0 00-1.898 0l-.683 2.051a1 1 0 01-.633.633l-2.051.683a1 1 0 000 1.898l2.051.684a1 1 0 01.633.632l.683 2.051a1 1 0 001.898 0l.683-2.051a1 1 0 01.633-.633l2.051-.683a1 1 0 000-1.898l-2.051-.683a1 1 0 01-.633-.633L6.95 5.684zM13.949 13.684a1 1 0 00-1.898 0l-.184.551a1 1 0 01-.632.633l-.551.183a1 1 0 000 1.898l.551.183a1 1 0 01.633.633l.183.551a1 1 0 001.898 0l.184-.551a1 1 0 01.632-.633l.551-.183a1 1 0 000-1.898l-.551-.184a1 1 0 01-.633-.632l-.183-.551z"
            )
        end
    end
end