module EmailAuth
  class EmailsLink
    def initialize(email:, redirect_path:)
        @email
        @redirect_path
    end

    def call
        return unless (user = FindsOrCreatesUser.new(email: @email).call)

        DeliversEmail.new(
            user: user,
            token: GeneratesToken.new(user: user).call,
            redirect_path: @redirect_path
        ).call
    end
  end
end