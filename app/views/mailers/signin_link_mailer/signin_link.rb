module Mailers
    module SigninLinkMailer
        class SigninLink < ::Mailers::ApplicationMailer
            def initialize(user:, token:, redirect_path:)
                @user = user
                @token = token
                @redirect_path = redirect_path
            end
            
            def template
                div(class: '!block flex justify-center', style: 'display: none;') do
                    render Shared::Logo.new
                end
                render PhlexUI::Card.new(class: "p-6 flex flex-col items-center gap-y-4") do
                    render PhlexUI::Typography::Muted.new { "Here is your sign-in link for PhlexUI. It expires in #{EmailAuth::GeneratesToken::TOKEN_SHELF_LIFE} minutes." }
                    render PhlexUI::Link.new(
                        variant: :primary, 
                        href: helpers.signin_authenticate_url(
                            token: @token,
                            redirect_path: @redirect_path
                        )
                    ) { "Sign in" }
                end
            end
        end
    end
end