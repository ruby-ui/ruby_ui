module EmailAuth
    include Phlex::Rails::Helpers::Routes

    module Helpers
        def current_user
            return unless helpers.session[:user_id]

            User.find(helpers.session[:user_id])
        rescue ActiveRecord::RecordNotFound
            nil
        end
    end
end