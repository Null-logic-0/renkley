module Onboarding
  class CompetitorsController < ApplicationController
    before_action :set_organization

    def create
      @competitor = @organization.companies.new(
        company_params.merge(kind: :competitor, source: :manual, position: next_position)
      )
      # The form only collects a URL — Company#normalizes strips it down to a
      # bare domain on assignment, so derive a display name from that.
      @competitor.name = @competitor.domain.to_s.split(".").first.to_s.capitalize if @competitor.name.blank?

      flash.now[:alert] = @competitor.errors.full_messages.to_sentence unless @competitor.save

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to onboarding_path }
      end
    end

    def destroy
      @competitor = @organization.companies.competitor.find(params[:id])
      @competitor.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to onboarding_path }
      end
    end

    private

    def set_organization
      @organization = Current.organization
    end

    def company_params
      params.require(:company).permit(:domain)
    end

    def next_position
      (@organization.companies.competitor.maximum(:position) || 0) + 1
    end
  end
end
