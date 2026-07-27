require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          full_name: "New Person",
          email_address: "new-person@example.com",
          password: "longenough1password"
        }
      }
    end

    user = User.find_by(email_address: "new-person@example.com")
    assert_not user.confirmed?
    assert_enqueued_email_with ConfirmationsMailer, :confirm, args: [ user ]
    assert_redirected_to sign_in_path
  end

  test "create with missing full name" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          full_name: "",
          email_address: "missing-name@example.com",
          password: "longenoughpassword"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with too short password" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          full_name: "Short Password",
          email_address: "short-password@example.com",
          password: "short"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with duplicate email" do
    existing = User.take

    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          full_name: "Duplicate Email",
          email_address: existing.email_address,
          password: "longenoughpassword"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
