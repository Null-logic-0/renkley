require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  # Turbo cannot follow the cross-origin redirect to Google, hence data-turbo="false".
  test "new renders the Google button as a post form that opts out of Turbo" do
    get new_session_path

    assert_response :success
    assert_select "form[action=?][method=?]", "/auth/google_oauth2", "post"
    assert_select "form[action=?][data-turbo=?]", "/auth/google_oauth2", "false"
  end

  test "omniauth signs in a new google user" do
    mock_google_auth(uid: "abc", email: "brand-new@example.com", name: "Brand New")

    assert_difference -> { User.count }, 1 do
      post omniauth_authorize_path(provider: "google_oauth2")
      follow_redirect!
    end

    assert_redirected_to root_url
    assert cookies[:session_id].present?
    assert_equal 1, User.find_by(uid: "abc").sessions.count
    assert_equal "Welcome to Renkley, let's get started!", flash[:notice]
  end

  test "omniauth signs in an existing google user without creating a record" do
    mock_google_auth(uid: "abc", email: "brand-new@example.com")
    post omniauth_authorize_path(provider: "google_oauth2")
    follow_redirect!
    delete session_path

    assert_no_difference -> { User.count } do
      post omniauth_authorize_path(provider: "google_oauth2")
      follow_redirect!
    end

    assert cookies[:session_id].present?
    assert_match "Welcome back", flash[:notice]
  end

  test "omniauth rejects an unverified google email" do
    mock_google_auth(uid: "nope", email: "spoofed@example.com", verified: false)

    assert_no_difference -> { User.count } do
      post omniauth_authorize_path(provider: "google_oauth2")
      follow_redirect!
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
    assert_equal "We couldn't verify that Google account.", flash[:alert]
  end

  test "provider failure redirects to sign in" do
    mock_google_failure(:access_denied)

    post omniauth_authorize_path(provider: "google_oauth2")
    follow_redirect!

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
  end

  test "omniauth_failure redirects to sign in when hit directly" do
    get auth_failure_path

    assert_redirected_to new_session_path
    assert_equal "Google sign-in was cancelled or failed.", flash[:alert]
  end

  test "omniauth_failure surfaces the reason outside production" do
    get auth_failure_path, params: { message: "csrf_detected" }

    assert_redirected_to new_session_path
    assert_match "csrf_detected", flash[:alert]
  end

  test "unknown providers are not routable" do
    get "/auth/facebook/callback"
    assert_response :not_found

    post "/auth/facebook"
    assert_response :not_found
  end
end
