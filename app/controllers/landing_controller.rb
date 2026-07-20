class LandingController < ApplicationController
  def index
    @features = Landing::FEATURES

    @hero_platforms = Landing::HERO_PLATFORMS

    @visibility_score = Landing::VISIBILITY_SCORE
    # @logos = Landing::LOGOS

    @preview_tabs = Landing::PREVIEW_TABS
    @preview_stats = Landing::PREVIEW_STATS
    @chart_data = Landing::CHART_DATA

    @pricing_plans = Landing::PRICING_PLANS
    @faqs = Landing::FAQS
  end
end
