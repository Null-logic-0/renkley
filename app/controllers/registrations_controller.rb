class RegistrationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_logged_in

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.organization = Organization.new(
      name: User.default_organization_name(@user.full_name, @user.email_address)
    )
    if @user.save
      ConfirmationsMailer.confirm(@user).deliver_later
      redirect_to sign_in_path, notice: "Welcome to Renkley! Check your email to confirm your account before signing in."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :full_name, :password, :password_confirmation)
  end
end
