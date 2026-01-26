require "test_helper"

class LoginUxTest < ActionDispatch::IntegrationTest
  test "login page has accessible labels" do
    get new_user_session_path
    assert_response :success

    # Check for email label
    assert_select "label[for=?]", "user_email", "Retpoŝtadreso"

    # Check for password label
    assert_select "label[for=?]", "user_password", "Pasvorto"
  end
end
