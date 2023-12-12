# frozen_string_literal: true

class Payments::ConfirmationView < ApplicationView
  register_element :turbo_frame

  def initialize(user:)
    @user = user
    @github_errors = @user.errors.full_messages_for(:github_username).join(", ") if @user.present?
  end

  def template
    render Shared::GridPattern.new
    
    div(class: "z-0 absolute inset-top grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 h-32 -mt-14") do
      6.times do
        render Animation.new(path: helpers.asset_path("confetti_animation.json"), delay: rand(5000), class: "h-full w-full col-span-1 rotate-12")
      end
    end

    div(class: 'pt-32 relative') do
      render PhlexUI::Card.new(class: 'p-4 sm:p-8 space-y-6 w-full rounded-none') do
        render Shared::Container.new(class: 'pt-10 space-y-8') do
          div(class: 'space-y-2 flex flex-col items-center') do
            render PhlexUI::Badge.new(variant: :success) { "Payment Successful" }
            render PhlexUI::Typography::H1.new(class: '!text-3xl') { "Welcome to PhlexUI!" }
            render PhlexUI::Typography::P.new(class: 'text-muted-foreground') { "Follow the steps below to get started." }
          end
          
          div(class: 'flex flex-col space-y-12 pt-10') do
            sign_in_step
            github_step
            installation_step
          end
        end
      end
    end
  end

  private

  def installation_step
    check_list_item(title: "Install PhlexUI", description: 'Install PhlexUI in your Ruby app.', checked: false) do
      render PhlexUI::Card.new(class: 'shadow-none p-6 space-y-4') do
        render PhlexUI::Typography::P.new { "Follow the installation guide to install PhlexUI in your Ruby app." }
        render PhlexUI::Link.new(href: helpers.docs_installation_path, variant: :primary, class: 'w-full') do 
          plain "Go to installation guide"
          arrow_right_icon
        end
      end
    end
  end

  def github_step
    check_list_item(title: "Connect your Github", description: 'Access the private PhlexUI repositories on GitHub.', checked: Current.user&.github_username.present?) do
      if Current.user&.github_username.present?
        render PhlexUI::Alert.new do
          render PhlexUI::Alert::Description.new { "Github connected. You can now access the private github repositories" }
        end
      else
        render PhlexUI::Card.new(class: 'shadow-none p-6') do
          github_form
        end
      end
    end
  end

  def sign_in_step
    check_list_item(title: "Sign in", description: 'Use the email you provided at payment to sign in to your account.', checked: Current.user.present?) do
      if Current.user.present?
        render PhlexUI::Alert.new do
          render PhlexUI::Alert::Description.new { "Nice work! You're signed in." }
        end
      else
        render PhlexUI::Card.new(class: 'shadow-none p-6') do
          sign_in_form
        end
      end
    end
  end

  def github_form
    div(class: 'scroll-m-20 block space-y-4') do
      render PhlexUI::Form.new(action: helpers.account_update_from_payment_confirmation_path, method: :patch) do
        render PhlexUI::Form::Spacer.new do
          render PhlexUI::Form::Item.new do
            render PhlexUI::Label.new(for: "github_username") { "GitHub username" }
            render PhlexUI::Input.new(type: "string", name: "user[github_username]", placeholder: "eg. joeldrapper", id: "github_username", value: @user&.github_username, error: @github_errors)
            render PhlexUI::Hint.new do
              plain "Only use your own account please 🙏 "
              a(href: "http://www.github.com", class: 'text-foreground underline') { "Find GitHub username" }
            end
          end
          
          div(class: 'flex gap-x-2') do
            render PhlexUI::Button.new(type: :submit, variant: :primary) { "Update" }
            if @user&.github_username.present?
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

  def sign_in_form
    render PhlexUI::Form::Builder.new(action: helpers.signin_path, method: :post, class: 'w-full space-y-0') do |f|
      render PhlexUI::Input.new(type: "hidden", value: helpers.payments_confirmation_path, name: "redirect_path")
      render PhlexUI::Form::Spacer.new do
        f.input :email, type: "email", placeholder: "Email", value: helpers.params[:email] || "", required: true
        render PhlexUI::Button.new(type: "submit", class: "w-full") { "Send sign-in link" }
      end
    end
    render PhlexUI::Typography::Muted.new(class: 'text-muted-foreground text-center mt-4 flex items-center justify-center') do
      sparkle_icon
      span { "We'll email a sign-in link" }
    end
  end

  def check_list_item(title:, description: nil, checked: false, &block)
    div(class: 'flex space-x-4') do
      render_check_state(checked)
      div(class: 'space-y-4 -mt-0.5 flex-grow') do
        div(class: 'space-y-1') do
          render PhlexUI::Typography::Large.new { title }
          render PhlexUI::Typography::P.new(class: 'text-muted-foreground') { description } if description.present?
        end

        block.call
      end
    end
  end

  def render_check_state(checked)
    div(class: 'pr-2 shrink-0') do
      if checked
        checked_icon
      else
        unchecked_icon
      end
    end
  end

  def checked_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-6 h-6"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm13.36-1.814a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.14-.094l3.75-5.25z",
        clip_rule: "evenodd"
      )
    end
  end

  def unchecked_icon
    div(class: 'w-6 h-6 rounded-full border bg-muted')
  end

  def sparkle_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      class: "w-3.5 h-3.5 text-amber-500 mr-1.5"
    ) do |s|
      s.path(
        d:
        "M15.98 1.804a1 1 0 00-1.96 0l-.24 1.192a1 1 0 01-.784.785l-1.192.238a1 1 0 000 1.962l1.192.238a1 1 0 01.785.785l.238 1.192a1 1 0 001.962 0l.238-1.192a1 1 0 01.785-.785l1.192-.238a1 1 0 000-1.962l-1.192-.238a1 1 0 01-.785-.785l-.238-1.192zM6.949 5.684a1 1 0 00-1.898 0l-.683 2.051a1 1 0 01-.633.633l-2.051.683a1 1 0 000 1.898l2.051.684a1 1 0 01.633.632l.683 2.051a1 1 0 001.898 0l.683-2.051a1 1 0 01.633-.633l2.051-.683a1 1 0 000-1.898l-2.051-.683a1 1 0 01-.633-.633L6.95 5.684zM13.949 13.684a1 1 0 00-1.898 0l-.184.551a1 1 0 01-.632.633l-.551.183a1 1 0 000 1.898l.551.183a1 1 0 01.633.633l.183.551a1 1 0 001.898 0l.184-.551a1 1 0 01.632-.633l.551-.183a1 1 0 000-1.898l-.551-.184a1 1 0 01-.633-.632l-.183-.551z"
      )
    end
  end

  def thumbs_up_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M6.633 10.5c.806 0 1.533-.446 2.031-1.08a9.041 9.041 0 012.861-2.4c.723-.384 1.35-.956 1.653-1.715a4.498 4.498 0 00.322-1.672V3a.75.75 0 01.75-.75A2.25 2.25 0 0116.5 4.5c0 1.152-.26 2.243-.723 3.218-.266.558.107 1.282.725 1.282h3.126c1.026 0 1.945.694 2.054 1.715.045.422.068.85.068 1.285a11.95 11.95 0 01-2.649 7.521c-.388.482-.987.729-1.605.729H13.48c-.483 0-.964-.078-1.423-.23l-3.114-1.04a4.501 4.501 0 00-1.423-.23H5.904M14.25 9h2.25M5.904 18.75c.083.205.173.405.27.602.197.4-.078.898-.523.898h-.908c-.889 0-1.713-.518-1.972-1.368a12 12 0 01-.521-3.507c0-1.553.295-3.036.831-4.398C3.387 10.203 4.167 9.75 5 9.75h1.053c.472 0 .745.556.5.96a8.958 8.958 0 00-1.302 4.665c0 1.194.232 2.333.654 3.375z"
      )
    end
  end

  def arrow_right_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 ml-2 mr-1.5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M4.5 12h15m0 0l-6.75-6.75M19.5 12l-6.75 6.75"
      )
    end
  end
end
