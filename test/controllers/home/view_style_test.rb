# frozen_string_literal: true

require "test_helper"

class HomeController::ViewStyleTest < ActionDispatch::IntegrationTest
  test "stores the selected view style and redirects to the home page" do
    get "/v/mapo", headers: {"HTTP_X_FORWARDED_PROTO" => "https"}

    assert_redirected_to root_path
    assert_equal "mapo", response.cookies["vidmaniero"]
  end
end
