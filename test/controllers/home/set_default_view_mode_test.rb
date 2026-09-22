# frozen_string_literal: true

require "test_helper"

class HomeController::SetDefaultViewModeTest < ActionDispatch::IntegrationTest
  test "sets the default view mode cookie when the visitor has no view mode cookie" do
    get root_url

    assert_response :success
    assert_equal "kalendaro", response.cookies["vidmaniero"]
  end

  test "sets the default view mode cookie when the visitor has an invalid view mode cookie" do
    get root_url, headers: {"HTTP_COOKIE" => "vidmaniero=nelonga"}

    assert_response :success
    assert_equal "kalendaro", response.cookies["vidmaniero"]
  end

  test "keeps a valid kalendaro view mode cookie untouched" do
    get root_url, headers: {"HTTP_COOKIE" => "vidmaniero=kalendaro"}

    assert_response :success
    assert_nil response.cookies["vidmaniero"]
  end

  test "keeps a valid mapo view mode cookie untouched" do
    get root_url, headers: {"HTTP_COOKIE" => "vidmaniero=mapo"}

    assert_response :success
    assert_nil response.cookies["vidmaniero"]
  end

  test "replaces a kartoj view mode cookie with the calendar default on the home page" do
    get root_url, headers: {"HTTP_COOKIE" => "vidmaniero=kartoj"}

    assert_redirected_to root_path
    assert_equal "kalendaro", response.cookies["vidmaniero"]
  end
end
