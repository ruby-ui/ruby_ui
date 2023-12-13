module Mailers
    module SigninLinkMailer
        class SigninLink < ::Mailers::BaseMailer
            def initialize(user:, token:, redirect_path:)
                @user = user
                @token = token
                @redirect_path = redirect_path
            end
            
            def template
                para { "Here is your sign-in link for PhlexUI. It expires in #{EmailAuth::GeneratesToken::TOKEN_SHELF_LIFE} minutes." }
                cta(href: helpers.signin_authenticate_url(
                    token: @token,
                    redirect_path: @redirect_path
                )) { "Sign in" }
            end
        end
    end
end