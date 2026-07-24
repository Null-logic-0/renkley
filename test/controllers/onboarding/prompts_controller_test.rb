require "test_helper"

class Onboarding::PromptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.create!(name: "Fresh Org")
    @user = User.create!(
      email_address: "fresh@example.com", full_name: "Fresh Person",
      password: "password123", confirmed_at: Time.current, organization: @organization
    )
    sign_in_as(@user)
  end

  test "create adds a prompt" do
    assert_difference -> { @organization.prompts.count }, 1 do
      post onboarding_prompts_path,
        params: { prompt: { body: "Best project management tool for agencies" } },
        as: :turbo_stream
    end

    assert_equal "Best project management tool for agencies", @organization.prompts.last.body
    assert_response :success
  end

  test "create rejects a blank prompt" do
    assert_no_difference -> { @organization.prompts.count } do
      post onboarding_prompts_path, params: { prompt: { body: "" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "destroy removes a prompt" do
    prompt = @organization.prompts.create!(body: "Alternatives to Rival")

    assert_difference -> { @organization.prompts.count }, -1 do
      delete onboarding_prompt_path(prompt), as: :turbo_stream
    end
  end

  test "destroy only removes the current organization's prompts" do
    other_organization = Organization.create!(name: "Other Org")
    other_prompt = other_organization.prompts.create!(body: "Other prompt")

    delete onboarding_prompt_path(other_prompt), as: :turbo_stream

    assert_response :not_found
    assert other_prompt.reload.persisted?
  end
end
