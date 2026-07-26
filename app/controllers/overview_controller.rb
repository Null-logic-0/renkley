class OverviewController < ApplicationController
  include EnforcesOnboarding
  layout "dashboard"

  def index
    VisibilityBackfillService.call(Current.organization)
    @overview = OverviewPresenter.new(Current.organization)
  end
end
