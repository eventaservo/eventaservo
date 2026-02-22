require "test_helper"

class Admin::CountriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index as admin" do
    sign_in users(:admin_user)
    get admin_countries_url
    assert_response :success
    assert_match "Afganio", response.body
  end

  test "should redirect index when not logged in" do
    get admin_countries_url
    assert_redirected_to new_user_session_path
  end

  test "should redirect index when not admin" do
    sign_in users(:user)
    get admin_countries_url
    assert_redirected_to root_path
  end
end
