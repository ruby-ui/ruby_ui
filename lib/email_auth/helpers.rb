module EmailAuth
    include Phlex::Rails::Helpers::Routes

    module Helpers
        def current_user
            return @current_user if defined?(@current_user)

            @current_user = begin
                User.find(helpers.session[:user_id]) if helpers.session[:user_id]
            rescue ActiveRecord::RecordNotFound
                nil
            end
        end
    end
end