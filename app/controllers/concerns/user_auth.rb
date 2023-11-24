module UserAuth
    extend ActiveSupport::Concern

    included do
        before_action :authenticate_user!
    end

    def authenticate_user!
        @current_user = User.find_by(id: session[:user_id])
        raise "No user is present" unless @current_user.present?

        redirect_to new_login_path(
        redirect_path: request.original_fullpath
        )
    end
end