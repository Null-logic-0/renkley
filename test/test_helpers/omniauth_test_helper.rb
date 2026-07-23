module OmniauthTestHelper
  def google_auth_hash(uid: "google-uid-1", email: "google@example.com", name: "Google Person", verified: true)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name, email_verified: verified },
      extra: { raw_info: { email_verified: verified } }
    )
  end

  def mock_google_auth(**)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(**)
  end

  def mock_google_failure(reason = :access_denied)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = reason
  end

  def reset_omniauth
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include OmniauthTestHelper

  teardown { reset_omniauth }
end
