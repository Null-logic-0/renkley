require "test_helper"

class RecommendationGeneratorServiceTest < ActiveSupport::TestCase
  test "generates a fresh set of recommendations from org data" do
    organization = organizations(:one)
    organization.recommendations.create!(
      title: "Stale", rationale: "old", priority: :low, category: "Content", effort: :easy, impact_score: 1
    )

    RecommendationGeneratorService.new(organization).call

    assert_equal RecommendationGeneratorService::TEMPLATES.length, organization.recommendations.count
    assert_not organization.recommendations.exists?(title: "Stale")
  end
end
