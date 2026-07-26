require "test_helper"

class RecommendationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
    @recommendation = @organization.recommendations.create!(
      title: "Test rec", rationale: "Because reasons",
      priority: :high, category: "Content", effort: :easy, impact_score: 8
    )
  end

  test "apply marks the recommendation applied" do
    post apply_recommendation_path(@recommendation), as: :turbo_stream
    assert_equal "applied", @recommendation.reload.status
  end

  test "dismiss marks the recommendation dismissed" do
    post dismiss_recommendation_path(@recommendation), as: :turbo_stream
    assert_equal "dismissed", @recommendation.reload.status
  end

  test "regenerate replaces recommendations from real org data" do
    @organization.companies.create!(name: "Rival", domain: "rival.com", kind: :competitor)

    post regenerate_recommendations_path, as: :turbo_stream

    assert @organization.recommendations.pending.count.positive?
    assert_not @organization.recommendations.exists?(@recommendation.id)
  end
end
