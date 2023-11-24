module EmailAuth
    class FindsOrCreatesUser
        def initialize(email:)
            @email = email
        end

        def call
            user = User.find_or_create_by(
                email: @email.strip.downcase
            )
            if user.persisted?
                user
            end
        end
    end
end