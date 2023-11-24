module Mailers
    module SigninLinkMailer
        class SigninLink < Phlex::HTML
            def initialize(user:, token:, redirect_path:)
                @user = user
                @token = token
                @redirect_path = redirect_path
            end
            def template
                p { "Hi #{@user.email}!" }
            end
        end
    end
end