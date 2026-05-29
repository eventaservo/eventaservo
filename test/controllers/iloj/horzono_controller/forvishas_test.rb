# frozen_string_literal: true

require "test_helper"

class Iloj::HorzonoController::ForvishasTest < ActionDispatch::IntegrationTest
  test "deletes the horzono cookie and redirects back to the referrer" do
    get "/iloj/forvishas_horzonon",
      headers: {
        "HTTP_REFERER" => "https://www.example.com/",
        "HTTPS" => "on",
        "HTTP_COOKIE" => "horzono=Europe/Berlin"
      }

    assert_redirected_to "https://www.example.com/"
    assert_nil response.cookies["horzono"]
    assert_equal "Horzona informo forviŝita sukcese", flash[:success]
  end

  test "redirects to root_url when no referrer is present" do
    get "/iloj/forvishas_horzonon", headers: {"HTTPS" => "on"}

    assert_redirected_to root_url
  end
end
