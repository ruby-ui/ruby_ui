class AccountsController < ApplicationController
    layout -> { ApplicationLayout }

    def show
        render Accounts::ShowView.new(user: Current.user)
    end

    def update
        user = Current.user
        if user.update(user_params)
            redirect_to account_path, notice: 'Account was successfully updated.'
        else
            render Accounts::ShowView.new(user: user), status: :unprocessable_entity
        end
    end

    def update_from_payment_confirmation
        user = Current.user
        if user.update(user_params)
            redirect_to payments_confirmation_path, notice: 'Github username was successfully updated'
        else
            render Payments::ConfirmationView.new(user: user), status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:github_username)
    end
end
