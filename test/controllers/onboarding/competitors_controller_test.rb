require "test_helper"

class Onboarding::CompetitorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.create!(name: "Fresh Org")
    @user = User.create!(
      email_address: "fresh@example.com", full_name: "Fresh Person",
      password: "password123", confirmed_at: Time.current, organization: @organization
    )
    sign_in_as(@user)
  end

  test "create adds a competitor derived from the domain" do
    assert_difference -> { @organization.companies.competitor.count }, 1 do
      post onboarding_competitors_path,
        params: { company: { domain: "https://rival.com" } },
        as: :turbo_stream
    end

    competitor = @organization.companies.competitor.last
    assert_equal "rival.com", competitor.domain
    assert_equal "Rival", competitor.name
    assert_response :success
  end

  test "create does not add a duplicate domain" do
    @organization.companies.create!(name: "Rival", domain: "rival.com", kind: :competitor)

    assert_no_difference -> { @organization.companies.competitor.count } do
      post onboarding_competitors_path,
        params: { company: { domain: "https://rival.com" } },
        as: :turbo_stream
    end

    assert_response :success
  end

  test "destroy removes a competitor" do
    competitor = @organization.companies.create!(name: "Rival", domain: "rival.com", kind: :competitor)

    assert_difference -> { @organization.companies.competitor.count }, -1 do
      delete onboarding_competitor_path(competitor), as: :turbo_stream
    end
  end

  test "destroy only removes the current organization's competitors" do
    other_organization = Organization.create!(name: "Other Org")
    other_competitor = other_organization.companies.create!(name: "Other", domain: "other.com", kind: :competitor)

    delete onboarding_competitor_path(other_competitor), as: :turbo_stream

    assert_response :not_found
    assert other_competitor.reload.persisted?
  end
end
