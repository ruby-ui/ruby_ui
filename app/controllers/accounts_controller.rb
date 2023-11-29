class AccountsController < ApplicationController
    layout -> { ApplicationLayout }

    def show
        render Accounts::ShowView.new
    end
end
