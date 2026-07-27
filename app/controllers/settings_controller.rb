class SettingsController < ApplicationController
  include EnforcesOnboarding
  layout "dashboard"

  def show
    @organization = Current.organization
  end


  def update
    @organization = Current.organization
    organization_saved = @organization.update(settings_params)
    password_saved = maybe_update_password

    if organization_saved && password_saved
      redirect_to settings_path, notice: "Settings saved."
    else
      errors = @organization.errors.full_messages + Current.user.errors.full_messages
      flash.now[:alert] = errors.to_sentence
      render :show, status: :unprocessable_entity
    end
  end


  def destroy
    organization = Current.organization
    terminate_session
    WorkspaceDeletionJob.perform_later(organization)
    redirect_to sign_in_path, notice: "Your workspace is being deleted."
  end

  private

  def settings_params
    params.require(:organization).permit(:name, :website_url, :category, :default_ai_platform, :scan_frequency)
  end

  def maybe_update_password
    return true if params[:password].blank?

    user = Current.user
    if !user.authenticate(params[:current_password].to_s)
      user.errors.add(:base, "Current password is incorrect.")
      false
    else
      user.update(params.permit(:password, :password_confirmation))
    end
  end
end
