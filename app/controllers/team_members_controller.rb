class TeamMembersController < ApplicationController
    def create
        # takes a parameter of emails, which is a comma-separated list of emails
        # creates a team member for each email
        # sends an email to each email address
        # redirects back to the account page
        emails = team_member_params[:emails].split(",").map(&:strip)
        emails.each do |email|
            team_member = TeamMember.create!(email: email, user: current_user)
            TeamMemberMailer.with(email: email, user: current_user).invite.deliver_now
        end
        redirect_to account_path, notice: "Team members invited!"

        rescue ActiveRecord::RecordInvalid => e
            redirect_to account_path, alert: "There was an error inviting your team members: #{e.record.errors.full_messages.join(", ")}. Please try again."
    end

    def destroy
        team_member = TeamMember.find(params[:id])
        team_member.destroy
        redirect_to account_path, notice: "Team member removed!"
    end

    private

    def team_member_params
        params.require(:team_member).permit(:emails)
    end
end
