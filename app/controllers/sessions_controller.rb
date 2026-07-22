class SessionsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[ new create omniauth omniauth_failure passthru ]
  skip_forgery_protection only: %i[ omniauth_failure ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user, remember: params[:remember_me].present?
      redirect_to after_authentication_url, notice: "Welcome back #{user.full_name}!"
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  def omniauth
    user = User.from_omniauth(request.env["omniauth.auth"])

    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: welcome_notice_for(user)
    else
      redirect_to new_session_path, alert: "We couldn't verify that Google account."
    end
  end

  def omniauth_failure
    type     = request.env["omniauth.error.type"] || params[:message]
    strategy = request.env["omniauth.error.strategy"]&.name

    Rails.logger.warn("[omniauth] #{strategy || "unknown"} failed: #{type} — #{request.env["omniauth.error"]&.message}")

    alert = "Google sign-in was cancelled or failed."
    alert += " (#{type})" if type.present? && !Rails.env.production?

    redirect_to new_session_path, alert: alert
  end

  def passthru
    head :not_found
  end

  private
    def welcome_notice_for(user)
      if user.previously_new_record?
        "Welcome to Renkley, let's get started!"
      else
        "Welcome back #{user.full_name}!"
      end
    end
end
