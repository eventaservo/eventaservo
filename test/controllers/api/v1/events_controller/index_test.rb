# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class EventsController::IndexTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:user)
      end

      test "index with missing params returns error" do
        get "/api/v1/events.json", headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
        assert_response :bad_request
        assert_equal "Mankas datoj aŭ eventa uuid", JSON.parse(response.body)["eraro"]
      end

      test "index with uuid returns event" do
        uuid = SecureRandom.uuid
        Event.create!(title: "Test Event", uuid: uuid, description: "Test description", city: "Test City", email: "test@example.com", date_start: 1.month.from_now, date_end: 1.month.from_now + 1.day, country_id: 1, user: @user)

        get "/api/v1/events.json", params: {uuid: uuid}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
        assert_response :success

        response_event = JSON.parse(response.body)[0]
        assert_equal uuid, response_event["uuid"]
      end

      test "index with invalid date format returns error" do
        get "/api/v1/events.json", params: {komenca_dato: "12-34-56", fina_dato: "12-34-56"}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
        assert_response :bad_request
        assert_equal "Data formato malĝustas", JSON.parse(response.body)["eraro"]
      end

      test "index with valid params returns events" do
        Event.create!(title: "Rails Conference", description: "Annual Rails conference", city: "New York", email: "info@railsconf.com", date_start: "2023-01-15", date_end: "2023-01-16", country_id: 1, user: @user)

        get "/api/v1/events.json", params: {komenca_dato: "2023-01-01", fina_dato: "2023-01-31"}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
        assert_response :success
        assert_equal 1, JSON.parse(response.body).count
      end
    end
  end
end
