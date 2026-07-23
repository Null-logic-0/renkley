class ConfirmationsMailer < ApplicationMailer
  def confirm(user)
    @user = user
    mail subject: "Confirm your email", to: user.email_address
  end
end
