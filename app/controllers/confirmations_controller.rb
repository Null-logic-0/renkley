class ConfirmationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      ConfirmationsMailer.confirm(user).deliver_later unless user.confirmed?
    end

    redirect_to new_session_path, notice: "Confirmation instructions sent (if an unconfirmed account with that email exists)."
  end

  def show
    user = User.find_by_token_for!(:confirmation, params[:token])
    user.confirm!
    redirect_to new_session_path, notice: "Email confirmed! You can now sign in."
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_confirmation_path, alert: "Confirmation link is invalid or has expired."
  end
end
