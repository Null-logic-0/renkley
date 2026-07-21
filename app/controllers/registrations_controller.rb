class RegistrationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_logged_in

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to sign_in_path, notice: "Welcome to Renkley, let's get started!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :full_name, :password, :password_confirmation)
  end
end
