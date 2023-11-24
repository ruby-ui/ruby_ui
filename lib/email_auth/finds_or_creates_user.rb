module EmailAuth
    class FindsOrCreatesUser
        def call(email)
            user = User.find_or_create_by(
                email: email.strip.downcase
            )
            if user.persisted?
                user
            end
        end
    end
end