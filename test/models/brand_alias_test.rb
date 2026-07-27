require "test_helper"

class BrandAliasTest < ActiveSupport::TestCase
  setup { @organization = organizations(:one) }

  test "requires a name" do
    alias_record = @organization.brand_aliases.new(name: "")
    assert_not alias_record.valid?
  end

  test "name is unique within an organization" do
    @organization.brand_aliases.create!(name: "Kestrel App")
    duplicate = @organization.brand_aliases.new(name: "Kestrel App")

    assert_not duplicate.valid?
  end

  test "the same alias name is allowed across different organizations" do
    @organization.brand_aliases.create!(name: "Kestrel App")
    other = organizations(:two).brand_aliases.new(name: "Kestrel App")

    assert other.valid?
  end
end
