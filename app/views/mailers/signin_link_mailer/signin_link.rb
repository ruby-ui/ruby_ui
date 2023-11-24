module Mailers
    module SigninLinkMailer
        class SigninLink < ::Mailers::ApplicationMailer
            def initialize(user:, token:, redirect_path:)
                @user = user
                @token = token
                @redirect_path = redirect_path
            end
            
            def template
                
                render Shared::Logo.new
                p do
                    plain " Here is your "
                    render PhlexUI::Link.new(variant: :link, href: helpers.signin_authenticate_url(
                                token: @token,
                                redirect_path: @redirect_path
                            )) { "link to sign-in" }
                    plain " for PhlexUI. It expires in "
                    plain EmailAuth::GeneratesToken::TOKEN_SHELF_LIFE
                    plain " minutes."
                end
            end
        end
    end
end