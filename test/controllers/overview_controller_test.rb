require "test_helper"

class OverviewControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @organization.companies.create!(name: "Rival", domain: "rival.com", kind: :competitor)
    @organization.prompts.create!(body: "Best tool for teams")
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get overview_url
    assert_response :success
  end

  test "backfills scan history on first visit" do
    assert_difference -> { @organization.scans.completed.count }, VisibilityBackfillService::SCAN_COUNT do
      get overview_url
    end
  end

  test "does not backfill again on subsequent visits" do
    get overview_url

    assert_no_difference -> { @organization.scans.count } do
      get overview_url
    end
  end

  test "renders real competitor and prompt data" do
    get overview_url

    assert_select "h1", /AI visibility score/
    assert_select ".rk-ov-comp-brand-name", text: "Rival"
    assert_select ".rk-ov-prompt-text", text: "Best tool for teams"
  end

  test "platform breakdown only shows platforms with a real integration" do
    get overview_url

    assert_select ".rk-ov-platform-name", count: AiPlatform.integrated.count, text: "Gemini"
  end
end
