module UserAuth
    extend ActiveSupport::Concern

    included do
        before_action :authenticate_user!
    end

    def authenticate_user!
        @current_user = User.find_by(id: session[:user_id])
        
        if @current_user.nil?
            flash[:notice] = "You must be signed in."
            redirect_to new_signin_path(
                redirect_path: request.original_fullpath
            )
        end
    end
end