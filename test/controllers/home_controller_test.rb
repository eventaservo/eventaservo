# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "renders index when visitor has a legacy timezone cookie" do
    cookies[:horzono] = "America/Buenos_Aires"

    get root_url
    assert_response :success
  end

  test "deletes the cookie when visitor has an invalid timezone" do
    cookies[:horzono] = "Invalid/Timezone"

    get root_url
    assert_response :success
    assert_nil response.cookies["horzono"]
  end

  test "should get instruantoj kaj prelegantoj" do
    get instruantoj_kaj_prelegantoj_url
    assert_response :success
  end

  test "should get instruantoj kaj prelegantoj with filters" do
    get instruantoj_kaj_prelegantoj_url, params: {name: "Test", country_id: 1, level: "Baza", keyword: "lingvo"}
    assert_response :success
  end
end
