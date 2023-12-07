# frozen_string_literal: true

class Accounts::ShowView < ApplicationView
  register_element :turbo_frame

  def initialize(user:)
    @user = user
    @github_errors = @user.errors.full_messages_for(:github_username).join(", ") if @user.errors[:github_username].present?
  end

  def template
    render Shared::GridPattern.new
    div(class: 'container max-w-lg mx-auto px-4 pb-24 space-y-16') do
      div(class: "space-y-4 py-16 md:py-24 md:pb-16 max-w-lg mx-auto") do
        render PhlexUI::Typography::H1.new(class: 'text-center') { "Account Settings" }
      end
      account_details
      github_access if Current.user_subscribed?
      current_plan
      upgrade_plan if ["free", "personal"].include?(Current.user.plan) && !Current.user.is_team_member?
      invite_team_members if Current.user.plan == "team"
    end
  end

  private

  def account_details
    div(class: 'space-y-4') do
      render PhlexUI::Typography::H2.new(class: 'text-xl border-none !pb-0') { "Account details" }
      render PhlexUI::Form::Item.new do
        render PhlexUI::Label.new(for: "email") { "Email" }
        render PhlexUI::Input.new(type: "email", placeholder: "Email", id: "email", value: Current.user.email, disabled: true, class: 'bg-background')
        render PhlexUI::Typography::Muted.new do
          plain "Change your email by contacting us at "
          a(href: support_email_link, class: 'text-foreground underline') { ENV['SUPPORT_EMAIL'] }
        end
      end
    end
  end

  def github_access
    turbo_frame(id: "github_access", class: 'block space-y-4') do
      render PhlexUI::Typography::H2.new(class: 'text-xl border-none !pb-0') { "GitHub access" }
      render PhlexUI::Typography::P.new(class: 'text-muted-foreground') { "By adding your github username, we will add you to the PhlexUI GitHub organization, giving you read access to all repositories." }
        
      render PhlexUI::Form.new(action: helpers.account_path, method: :patch, class: 'pt-2') do
        render PhlexUI::Form::Spacer.new do
          render PhlexUI::Form::Item.new do
            render PhlexUI::Label.new(for: "github_username") { "GitHub username" }
            render PhlexUI::Input.new(type: "string", name: "user[github_username]", placeholder: "eg. joeldrapper", id: "github_username", value: Current.user.github_username, error: @github_errors)
            render PhlexUI::Hint.new do
              plain "Only use your own account please 🙏 "
              a(href: "http://www.github.com", class: 'text-foreground underline') { "Find GitHub username" }
            end
          end
          
          div(class: 'flex gap-x-2') do
            render PhlexUI::Button.new(type: :submit, variant: :primary) { "Update" }
            if Current.user.github_username.present?
              render PhlexUI::Link.new(href: ENV['PHLEXUI_GITHUB_LINK'], variant: :secondary) do
                github_icon
                plain "Go to PhlexUI"
              end
            end
          end
        end
      end
    end
  end

  def current_plan
    div(class: 'space-y-4') do
      render PhlexUI::Typography::H2.new(class: 'text-xl border-none !pb-0') { "Current plan" }
      if Current.user.is_team_member?
        render PhlexUI::Typography::P.new(class: 'text-muted-foreground') do
          plain "You are currently a team member of "
          render PhlexUI::Badge.new(variant: :primary, size: :sm) { Current.user.team_member&.user&.email }
          plain " and have access to all components."
        end
      else
        render PhlexUI::Typography::P.new(class: 'text-muted-foreground')  do
          plain "Currently you are on the "
          render PhlexUI::Badge.new(variant: :primary, size: :sm) { Current.user.plan.capitalize }
          plain " plan."
        end
      end
    end
  end

  def upgrade_plan
    cta_link = Current.user.plan == "free" ? helpers.root_path(anchor: :pricing) : ENV['TEAM_STRIPE_LINK'] + "?prefilled_email=#{Current.user.email}"

    div(class: 'space-y-4') do
      render PhlexUI::Typography::H2.new(class: 'text-xl border-none !pb-0') { "Upgrade plan" }
      render PhlexUI::Card.new(class: 'overflow-hidden') do
        render PhlexUI::AspectRatio.new(aspect_ratio: "4/1", class: "-m-px") do
          img(
            alt: "Placeholder",
            loading: "lazy",
            src:
              helpers.image_path('pattern.jpg')
          )
        end

        div(class: 'p-6') do
          case Current.user.plan
          when "free"
            render PhlexUI::Typography::P.new(class: 'font-semibold') { "Ready for unlimited access?" }
            render PhlexUI::Typography::P.new(class: '!mt-0 text-muted-foreground') { "Upgrade now to unlock all features and accelerate your productivity." }
          when "personal"
            render PhlexUI::Typography::P.new(class: 'font-semibold') { "Supercharge your team with PhlexUI" }
            render PhlexUI::Typography::P.new(class: '!mt-0 text-muted-foreground') { "Upgrade to a Team Plan and empower your team with access to all components. Streamline your design process and boost your business efficiency." }
          end
          div(class: 'flex justify-end') do
            render PhlexUI::Link.new(href: cta_link, variant: :primary, class: 'mt-4') { "Upgrade to all access" }
          end
        end
      end
    end
  end

  def invite_team_members
    div(class: 'space-y-4') do
      div(class: 'flex items-center justify-between') do
        render PhlexUI::Typography::H2.new(class: 'text-xl border-none !pb-0') { "Invite team members" }
        invite_modal
      end
      render PhlexUI::Card.new(class: 'overflow-hidden') do
        render PhlexUI::Table.new do
          render PhlexUI::Table::Header.new do
            render PhlexUI::Table::Row.new do
              render PhlexUI::Table::Head.new(class: 'pl-4') { "Email" }
              render PhlexUI::Table::Head.new(class: "text-right") { "" }
            end
          end
          render PhlexUI::Table::Body.new do
            Current.user.team_members.each do |member|
              render PhlexUI::Table::Row.new(class: 'group/row') do
                render PhlexUI::Table::Cell.new(class: 'pl-4 font-medium') { member.email }
                render PhlexUI::Table::Cell.new(class: "text-right opacity-0 group-hover/row:opacity-100 pr-4") do
                  delete_team_member_alert(member)
                end
              end
            end
          end
        end
        if Current.user.team_members.empty?
          render PhlexUI::Typography::Muted.new(class: 'text-center p-4') { "You have no team members yet..." }
        end
      end
    end
  end

  def support_email_link
    "mailto:#{ENV['SUPPORT_EMAIL']}?subject=#{email_subject}&body=#{email_body}"
  end

  def email_subject
    "Update my email please 🙏"
  end

  def email_body
    "Hi George,%0A%0AI'd like to update the email for my account.%0A%0ACurrent email: #{Current.user.email}%0ANew email: _INSERT_NEW_EMAIL_HERE_%0A%0ACheers"
  end

  def invite_modal
    render PhlexUI::Dialog.new do
      render PhlexUI::Dialog::Trigger.new do
        render PhlexUI::Button.new(variant: :primary, size: :sm) do
          plus_icon
          plain "Invite"
        end
      end
      render PhlexUI::Dialog::Content.new(size: :sm) do
        render PhlexUI::Dialog::Header.new do
          render PhlexUI::Dialog::Title.new { "Invite a member" }
          render PhlexUI::Dialog::Description.new { "Type their email below and we'll send them an invite." }
        end
        render PhlexUI::Form.new(action: helpers.team_members_path, method: :post, class: 'pt-2') do
          render PhlexUI::Form::Item.new do
            render PhlexUI::Label.new(for: "emails") { "Emails" }
            render PhlexUI::Input.new(type: "string", name: "team_member[emails]", placeholder: "user1@mail.com, user2@mail.com", id: "emails")
            render PhlexUI::Hint.new { "Separate multiple emails with commas" }
          end
          render PhlexUI::Dialog::Footer.new(class: 'pt-7') do
            render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
            render PhlexUI::Button.new(type: :submit) { "Send invites" }
          end
        end
      end
    end
  end

  def plus_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-3 h-3 mr-1 -ml-0.5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M12 4.5v15m7.5-7.5h-15"
      )
    end
  end

  def delete_team_member_alert(member)
    render PhlexUI::AlertDialog.new do
      render PhlexUI::AlertDialog::Trigger.new do
        render PhlexUI::Button.new(variant: :destructive, size: :sm) { "Remove" }
      end
      render PhlexUI::AlertDialog::Content.new do
        render PhlexUI::AlertDialog::Header.new do
          render PhlexUI::AlertDialog::Title.new { "Are you sure?" }
          render PhlexUI::AlertDialog::Description.new { "You can always invite them back later." }
        end
        render PhlexUI::AlertDialog::Footer.new do
          render PhlexUI::AlertDialog::Cancel.new { "Cancel" }
          render PhlexUI::Link.new(href: helpers.team_member_path(member.id), variant: :primary, data: { turbo_method: :delete }) { "Go ahead" }
        end
      end
    end
  end

  def github_icon
    svg(
      viewbox: "0 0 16 16",
      class: "w-4 h-4 -ml-1 mr-2",
      fill: "currentColor",
      aria_hidden: "true"
    ) do |s|
      s.path(
        d:
          "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"
      )
    end
  end

  def chevron_down_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 ml-1 -mr-0.5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M19.5 8.25l-7.5 7.5-7.5-7.5"
      )
    end
  end
end
