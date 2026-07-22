require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "confirmed? reflects confirmed_at" do
    user = User.new(confirmed_at: nil)
    assert_not user.confirmed?

    user.confirmed_at = Time.current
    assert user.confirmed?
  end

  test "confirm! sets confirmed_at" do
    user = User.take
    user.update!(confirmed_at: nil)

    user.confirm!

    assert user.confirmed?
  end
end
