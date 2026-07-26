class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: %i[apply dismiss]

  def apply
    @recommendation.update!(status: :applied)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path, notice: "Marked “#{@recommendation.title}” as applied." }
    end
  end

  def dismiss
    @recommendation.update!(status: :dismissed)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path, notice: "Dismissed that recommendation." }
    end
  end

  def regenerate
    RecommendationGeneratorService.new(Current.organization).call

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path, notice: "Regenerated your optimization recommendations." }
    end
  end

  private

  def set_recommendation
    @recommendation = Current.organization.recommendations.find(params[:id])
  end
end
