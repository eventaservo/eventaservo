# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "rewrites the horzono cookie when visitor has a legacy timezone" do
    get root_url, headers: {"HTTP_COOKIE" => "horzono=America/Buenos_Aires"}

    assert_response :success
    assert_equal "America/Argentina/Buenos_Aires", response.cookies["horzono"]
  end

  test "deletes the horzono cookie when visitor has an invalid timezone" do
    get root_url, headers: {"HTTP_COOKIE" => "horzono=Invalid/Timezone"}

    assert_response :success
    assert_nil response.cookies["horzono"]
  end

  test "leaves a valid horzono cookie untouched" do
    get root_url, headers: {"HTTP_COOKIE" => "horzono=Europe/Berlin"}

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
