# frozen_string_literal: true

require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "listigas eventojn" do
    uzanto = create(:uzanto)
    evento = create(:evento, :brazila)

    get "/api/v1/events.json",
        params: {
          user_email: uzanto.email, user_token: uzanto.authentication_token,
          komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
          fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
        }
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal evento.code, json[0]["kodo"]
  end
end
