module EmailAuth
    include Phlex::Rails::Helpers::Routes

    module Helpers
        def current_user
            Current.user
        end
    end
end