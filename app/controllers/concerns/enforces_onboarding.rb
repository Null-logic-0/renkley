# Keeps a signed-in user with an unfinished onboarding on the onboarding
# flow instead of letting them navigate straight to dashboard pages —
# include in controllers that should only be reachable once onboarding is
# complete or skipped. Does not touch the auth flow itself: this only fires
# for already-authenticated requests (require_authentication, included in
# ApplicationController, already ran and would have redirected otherwise).
module EnforcesOnboarding
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_onboarding_if_pending
  end

  private

  def redirect_to_onboarding_if_pending
    redirect_to onboarding_path if authenticated? && Current.organization&.in_progress?
  end
end
