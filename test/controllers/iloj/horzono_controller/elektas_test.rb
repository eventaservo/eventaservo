# frozen_string_literal: true

require "test_helper"

class Iloj::HorzonoController::ElektasTest < ActionDispatch::IntegrationTest
  HTTPS_HEADERS = {
    "HTTP_REFERER" => "https://www.example.com/",
    "HTTPS" => "on"
  }.freeze

  test "stores a valid timezone cookie as-is" do
    post "/iloj/elektas_horzonon", params: {horzono: "Europe/Berlin"}, headers: HTTPS_HEADERS

    assert_equal "Europe/Berlin", response.cookies["horzono"]
    assert_equal "Horzono elektita sukcese", flash[:success]
  end

  test "normalizes a legacy timezone before storing it" do
    post "/iloj/elektas_horzonon", params: {horzono: "Europe/Kiev"}, headers: HTTPS_HEADERS

    assert_equal "Europe/Kyiv", response.cookies["horzono"]
  end

  test "normalizes America/Buenos_Aires before storing it" do
    post "/iloj/elektas_horzonon", params: {horzono: "America/Buenos_Aires"}, headers: HTTPS_HEADERS

    assert_equal "America/Argentina/Buenos_Aires", response.cookies["horzono"]
  end

  test "rejects invalid timezone without writing a cookie" do
    post "/iloj/elektas_horzonon", params: {horzono: "Invalid/Timezone"}, headers: HTTPS_HEADERS

    assert_nil response.cookies["horzono"]
    assert_equal "Nevalida horzono", flash[:error]
  end

  test "rejects blank timezone" do
    post "/iloj/elektas_horzonon", params: {horzono: ""}, headers: HTTPS_HEADERS

    assert_nil response.cookies["horzono"]
    assert_equal "Nevalida horzono", flash[:error]
  end
end
