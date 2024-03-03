module EmailAuth
  class ValidatesLoginAttempt
    Result = Struct.new(:success?, :user, keyword_init: true)

    def validate(token)
      user = User.where(auth_token: token)
        .where("auth_token_expires_at > ?", Time.now.utc)
        .first

      if user.present?
        Result.new(success?: true, user: user)
      else
        Result.new(success?: false)
      end
    end
  end
end
