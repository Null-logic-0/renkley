require "test_helper"

class Settings::BrandAliasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "create adds a brand alias" do
    assert_difference -> { @organization.brand_aliases.count }, 1 do
      post settings_brand_aliases_path, params: { brand_alias: { name: "Kestrel App" } }, as: :turbo_stream
    end

    assert_equal "Kestrel App", @organization.brand_aliases.last.name
    assert_response :success
  end

  test "create rejects a blank alias" do
    assert_no_difference -> { @organization.brand_aliases.count } do
      post settings_brand_aliases_path, params: { brand_alias: { name: "" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "destroy removes a brand alias" do
    brand_alias = @organization.brand_aliases.create!(name: "Kestrel App")

    assert_difference -> { @organization.brand_aliases.count }, -1 do
      delete settings_brand_alias_path(brand_alias), as: :turbo_stream
    end
  end

  test "cannot destroy another organization's brand alias" do
    other_organization = Organization.create!(name: "Other Org")
    other_alias = other_organization.brand_aliases.create!(name: "Not yours")

    delete settings_brand_alias_path(other_alias), as: :turbo_stream

    assert_response :not_found
    assert other_alias.reload.persisted?
  end
end
