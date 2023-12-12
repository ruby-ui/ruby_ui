module Mailers
    module SigninLinkMailer
        class SigninLink < Phlex::HTML
            def initialize(user:, token:, redirect_path:)
                @user = user
                @token = token
                @redirect_path = redirect_path
            end
            
            def template
                p { "Here is your sign-in link for PhlexUI. It expires in #{EmailAuth::GeneratesToken::TOKEN_SHELF_LIFE} minutes." }
                a(href: helpers.signin_authenticate_url(
                    token: @token,
                    redirect_path: @redirect_path
                ), class: 'button') { "Sign in" }
            end
        end
    end
end