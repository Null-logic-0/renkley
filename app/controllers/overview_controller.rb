class OverviewController < ApplicationController
  include EnforcesOnboarding
  layout "dashboard"

  def index
    @competitors = Current.organization.companies.competitor.ordered
    @prompts = Current.organization.prompts.ordered
  end
end
