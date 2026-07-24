require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "generates a slug from the name" do
    organization = Organization.create!(name: "Rocket Labs")
    assert_equal "rocket-labs", organization.slug
  end

  test "disambiguates a slug collision" do
    Organization.create!(name: "Rocket Labs")
    second = Organization.create!(name: "Rocket Labs")

    assert_equal "rocket-labs-2", second.slug
  end

  test "does not overwrite an explicitly assigned slug" do
    organization = Organization.create!(name: "Rocket Labs", slug: "custom-slug")
    assert_equal "custom-slug", organization.slug
  end

  test "onboarding_step_name maps the current step to its name" do
    organization = organizations(:one)

    organization.onboarding_step = 1
    assert_equal "website", organization.onboarding_step_name

    organization.onboarding_step = 3
    assert_equal "prompts", organization.onboarding_step_name

    organization.onboarding_step = 4
    assert_equal "setup", organization.onboarding_step_name
  end

  test "defaults to in_progress onboarding_status" do
    organization = Organization.create!(name: "Fresh Org")
    assert organization.in_progress?
  end
end
