require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "from_omniauth creates a user for a new verified google account" do
    user = nil

    assert_difference -> { User.count }, 1 do
      user = User.from_omniauth(google_auth_hash(uid: "abc", email: "brand-new@example.com", name: "Brand New"))
    end

    assert user.persisted?
    assert_equal "google_oauth2", user.provider
    assert_equal "abc", user.uid
    assert_equal "brand-new@example.com", user.email_address
    assert_equal "Brand New", user.full_name
  end

  test "from_omniauth gives the new user a usable password digest" do
    user = User.from_omniauth(google_auth_hash(uid: "abc", email: "brand-new@example.com"))

    assert user.password_digest.present?
    assert_nil User.authenticate_by(email_address: user.email_address, password: "password")
  end

  test "from_omniauth returns the existing user for a known provider and uid" do
    existing = User.from_omniauth(google_auth_hash(uid: "abc", email: "brand-new@example.com"))

    assert_no_difference -> { User.count } do
      assert_equal existing, User.from_omniauth(google_auth_hash(uid: "abc", email: "brand-new@example.com"))
    end
  end

  test "from_omniauth matches on uid even when the google email has changed" do
    existing = User.from_omniauth(google_auth_hash(uid: "abc", email: "old@example.com"))

    found = User.from_omniauth(google_auth_hash(uid: "abc", email: "changed@example.com"))

    assert_equal existing, found
    assert_equal "old@example.com", found.email_address
  end

  test "from_omniauth links a verified email to an existing password account" do
    existing = users(:one)

    assert_no_difference -> { User.count } do
      User.from_omniauth(google_auth_hash(uid: "xyz", email: existing.email_address, name: "Ignored Name"))
    end

    existing.reload
    assert_equal "xyz", existing.uid
    assert_equal "google_oauth2", existing.provider
    assert_equal "One Example", existing.full_name
  end

  test "from_omniauth keeps the existing password working after linking" do
    existing = users(:one)

    User.from_omniauth(google_auth_hash(uid: "xyz", email: existing.email_address))

    assert User.authenticate_by(email_address: existing.email_address, password: "password")
  end

  test "from_omniauth refuses an unverified email" do
    assert_no_difference -> { User.count } do
      assert_nil User.from_omniauth(google_auth_hash(uid: "nope", email: "spoofed@example.com", verified: false))
    end
  end

  test "from_omniauth refuses to link an unverified email to an existing account" do
    existing = users(:one)

    assert_nil User.from_omniauth(google_auth_hash(uid: "nope", email: existing.email_address, verified: false))
    assert_nil existing.reload.uid
  end

  test "from_omniauth refuses a missing email" do
    assert_no_difference -> { User.count } do
      assert_nil User.from_omniauth(google_auth_hash(uid: "nope", email: nil))
    end
  end

  test "from_omniauth falls back to raw_info when info omits email_verified" do
    auth = google_auth_hash(uid: "raw", email: "raw@example.com")
    auth.info.delete("email_verified")

    assert_difference -> { User.count }, 1 do
      assert User.from_omniauth(auth)
    end
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
