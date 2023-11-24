module EmailAuth
    class DeliversEmail
        def initialize(user:, token:, redirect_path:)
            @user = user
            @token = token
            @redirect_path = redirect_path
        end

        def call
            SigninLinkMailer.with(
                user: @user,
                token: @token,
                redirect_path: @redirect_path
            ).login_link.deliver_now # change to deliver_later if you want to send it asynchronously
        end
    end
end