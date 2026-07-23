require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "signed out header offers sign in and the trial CTA" do
    get root_path

    assert_response :success
    assert_select "a[href=?]", sign_in_path
    assert_select "form[action=?]", session_path, count: 0
  end

  test "signed in header offers sign out instead of sign in" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
    assert_select "a[href=?]", sign_in_path, count: 0
    assert_select "form[action=?][method=?]", session_path, "post"
    assert_select "input[name=_method][value=delete]"
  end

  test "signed in header greets the user by name" do
    sign_in_as users(:one)

    get root_path

    assert_select ".rk-nav-user", text: users(:one).full_name
  end
end
