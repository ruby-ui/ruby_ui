module UserAuth
    extend ActiveSupport::Concern

    included do
        before_action :require_login
    end

    def require_login
        @current_user = User.find_by(id: session[:user_id])
        return if @current_user.present?

        redirect_to new_login_email_path(
        redirect_path: request.original_fullpath
        )
    end

    def self.skip_require_login!
        skip_before_action :require_login
    end
end