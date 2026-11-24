# frozen_string_literal: true

require "test_helper"

class HomeController::ViewStyleTest < ActionDispatch::IntegrationTest
  test "stores the selected view style and redirects to the home page" do
    get "/v/mapo", headers: {"HTTP_X_FORWARDED_PROTO" => "https"}

    assert_redirected_to root_path
    assert_equal "mapo", response.cookies["vidmaniero"]
  end

  test "ignores Turbo prefetch requests without changing the view style cookie" do
    get "/v/mapo", headers: {
      "HTTP_X_FORWARDED_PROTO" => "https",
      "X-Sec-Purpose" => "prefetch"
    }

    assert_response :no_content
    assert_nil response.cookies["vidmaniero"]
  end

  test "ignores browser Sec-Purpose prefetch requests without changing the view style cookie" do
    get "/v/mapo", headers: {
      "HTTP_X_FORWARDED_PROTO" => "https",
      "Sec-Purpose" => "prefetch;anonymous-client-ip"
    }

    assert_response :no_content
    assert_nil response.cookies["vidmaniero"]
  end

  test "navbar view style links disable turbo prefetch" do
    get root_url, headers: {"Cookie" => "vidmaniero=kalendaro"}
    assert_response :success
    assert_select "a[href*='/v/mapo'][data-turbo-prefetch='false']", count: 2

    get root_url, headers: {"Cookie" => "vidmaniero=mapo"}
    assert_response :success
    assert_select "a[href*='/v/kalendaro'][data-turbo-prefetch='false']", count: 2
  end
end
