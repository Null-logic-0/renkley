require "test_helper"

class PromptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "create adds a tracked prompt" do
    assert_difference -> { @organization.prompts.count }, 1 do
      post prompts_path, params: { prompt: { body: "Best tool for remote teams", search_volume: "high" } }, as: :turbo_stream
    end

    prompt = @organization.prompts.last
    assert_equal "Best tool for remote teams", prompt.body
    assert_equal "high", prompt.search_volume
    assert_response :success
  end

  test "create rejects a blank prompt" do
    assert_no_difference -> { @organization.prompts.count } do
      post prompts_path, params: { prompt: { body: "" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "update changes an existing prompt's body and volume" do
    prompt = @organization.prompts.create!(body: "Old prompt", search_volume: "low")

    patch prompt_path(prompt), params: { prompt: { body: "New prompt", search_volume: "high" } }, as: :turbo_stream

    prompt.reload
    assert_equal "New prompt", prompt.body
    assert_equal "high", prompt.search_volume
  end

  test "destroy removes a prompt" do
    prompt = @organization.prompts.create!(body: "Doomed prompt")

    assert_difference -> { @organization.prompts.count }, -1 do
      delete prompt_path(prompt), as: :turbo_stream
    end
  end

  test "cannot update or destroy another organization's prompt" do
    other_organization = Organization.create!(name: "Other Org")
    other_prompt = other_organization.prompts.create!(body: "Not yours")

    patch prompt_path(other_prompt), params: { prompt: { body: "Hijacked" } }, as: :turbo_stream
    assert_response :not_found
    assert_equal "Not yours", other_prompt.reload.body

    delete prompt_path(other_prompt), as: :turbo_stream
    assert_response :not_found
    assert other_prompt.reload.persisted?
  end
end
