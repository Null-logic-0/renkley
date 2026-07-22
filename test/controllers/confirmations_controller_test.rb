require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take.tap { |u| u.update!(confirmed_at: nil) } }

  test "new" do
    get new_confirmation_path
    assert_response :success
  end

  test "create" do
    post confirmations_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with ConfirmationsMailer, :confirm, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Confirmation instructions sent"
  end

  test "create for an unknown user redirects but sends no mail" do
    post confirmations_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Confirmation instructions sent"
  end

  test "create for an already confirmed user sends no mail" do
    @user.update!(confirmed_at: Time.current)

    post confirmations_path, params: { email_address: @user.email_address }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path
  end

  test "show confirms the user" do
    assert_changes -> { @user.reload.confirmed? }, from: false, to: true do
      get confirmation_path(@user.generate_token_for(:confirmation))
    end

    assert_redirected_to new_session_path
    follow_redirect!
    assert_notice "Email confirmed"
  end

  test "show with invalid confirmation token" do
    get confirmation_path("invalid token")

    assert_redirected_to new_confirmation_path
    assert_not @user.reload.confirmed?

    follow_redirect!
    assert_notice "Confirmation link is invalid"
  end
end
