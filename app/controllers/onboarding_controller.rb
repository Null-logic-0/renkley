class OnboardingController < ApplicationController
  layout "onboarding"

  before_action :set_organization
  before_action :redirect_if_onboarding_done

  def show
    case @organization.onboarding_step_name
    when "competitors"
      @competitors = @organization.companies.competitor.ordered
    when "prompts"
      @prompts = @organization.prompts.ordered
    when "setup"
      @tasks = @organization.onboarding_tasks.ordered
    end
  end

  def scan
    website_url = params[:website_url].to_s.strip

    if website_url.blank?
      redirect_to onboarding_path, alert: "Enter your website URL to continue."
      return
    end

    @organization.update!(website_url: website_url)
    CompetitorDiscoveryJob.perform_later(@organization)
    advance_to(2)
  end

  def next_step
    advance_to(@organization.onboarding_step + 1)
  end

  def back
    @organization.update!(onboarding_step: [ @organization.onboarding_step - 1, 1 ].max)
    redirect_to onboarding_path
  end

  def finish
    advance_to(Organization::ONBOARDING_STEPS.length)
    OnboardingTask.seed_for!(@organization)
    OnboardingSetupJob.perform_later(@organization)
  end

  def skip
    @organization.update!(onboarding_status: :skipped)
    redirect_to overview_path, notice: "You can add competitors and prompts anytime from your dashboard."
  end

  private

  def set_organization
    @organization = Current.organization
  end

  def redirect_if_onboarding_done
    redirect_to overview_path if @organization.completed? || @organization.skipped?
  end

  def advance_to(step)
    @organization.update!(onboarding_step: step)
    redirect_to onboarding_path
  end
end
