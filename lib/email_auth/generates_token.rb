module EmailAuth
    class GeneratesToken
        TOKEN_SHELF_LIFE = 30

        def initialize(user:)
            @user = user
        end

        def call
            unless @user.auth_token.present? && @user.auth_token_expires_at.future?
                @user.update!(
                    auth_token: SecureRandom.urlsafe_base64,
                    auth_token_expires_at: TOKEN_SHELF_LIFE.minutes.from_now.utc
                )
            end
            @user.auth_token
        end
    end
end