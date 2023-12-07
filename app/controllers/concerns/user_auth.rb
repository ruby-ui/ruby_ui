module UserAuth
    extend ActiveSupport::Concern

    included do
        before_action :set_current_user
        before_action :authenticate_user!
    end

    def set_current_user
        Current.user = User.find_by(id: session[:user_id])
    end

    def authenticate_user!
        if Current.user.nil?
            flash[:notice] = "You must be signed in."
            redirect_to new_signin_path(
                redirect_path: request.original_fullpath
            )
        end
    end

    def current_user
        Current.user
    end
end