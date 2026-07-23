# OmniAuth derives redirect_uri from the incoming request host, so browsing via
# 127.0.0.1 instead of localhost sends Google a URI it doesn't recognise. Pin it
# in development so it always matches the one registered in the Google console.
#
# Browse the app at http://localhost:3000 to match. Starting the flow on
# 127.0.0.1 sends the callback here instead, and because the two hosts have
# separate cookie jars the CSRF state is lost and the callback fails.
OmniAuth.config.full_host = "http://localhost:3000" if Rails.env.development?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id),
    Rails.application.credentials.dig(:google, :client_secret),
    scope: "email,profile"
end

# Route provider-side failures (denied consent, csrf, invalid client) through
# our own controller instead of OmniAuth's default /auth/failure.
OmniAuth.config.on_failure = proc { |env|
  SessionsController.action(:omniauth_failure).call(env)
}
