# frozen_string_literal: true

require "test_helper"

class HomeController::NearbyTest < ActionDispatch::IntegrationTest
  test "nearby/off sets nearby cookie to 0 and redirects back to referer" do
    get "/nearby/off",
      headers: {"HTTP_REFERER" => "/europo/danio/kopenhago", "HTTP_X_FORWARDED_PROTO" => "https"}

    assert_redirected_to "/europo/danio/kopenhago"
    assert_equal "0", response.cookies["nearby"]
  end

  test "nearby/on sets nearby cookie to 1 and redirects to root when no referer" do
    get "/nearby/on", headers: {"HTTP_X_FORWARDED_PROTO" => "https"}

    assert_redirected_to root_path
    assert_equal "1", response.cookies["nearby"]
  end
end
