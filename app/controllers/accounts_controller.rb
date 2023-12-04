class AccountsController < ApplicationController
    layout -> { ApplicationLayout }

    def show
        render Accounts::ShowView.new(user: current_user)
    end

    def update
        user = current_user
        if user.update(user_params)
            redirect_to account_path, notice: 'Account was successfully updated.'
        else
            render Accounts::ShowView.new(user: user), status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:github_username)
    end
end
