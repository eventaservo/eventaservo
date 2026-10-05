# frozen_string_literal: true

require "test_helper"

class Iloj::MallongiloController::DisponeblasTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_HEADERS = {
    "HTTPS" => "on",
    "Accept" => "text/vnd.turbo-stream.html"
  }.freeze

  UNAVAILABLE_MESSAGE = "ne estas disponebla"

  setup do
    @event = events(:valid_event)
    @event.update!(short_url: "kukun")
  end

  test "treats a missing mallongilo param as available" do
    get "/iloj/mallongilo_disponeblas", headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_not_includes response.body, UNAVAILABLE_MESSAGE
  end

  test "treats a blank mallongilo param as available" do
    get "/iloj/mallongilo_disponeblas", params: {id: @event.id, mallongilo: ""}, headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_not_includes response.body, UNAVAILABLE_MESSAGE
  end

  test "marks a mallongilo already taken by another event as unavailable" do
    other = events(:esperanto_meetup)
    other.update!(short_url: "esperanto-meetup")

    get "/iloj/mallongilo_disponeblas", params: {id: @event.id, mallongilo: "Esperanto-Meetup"}, headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_includes response.body, UNAVAILABLE_MESSAGE
  end

  test "marks a mallongilo reserved by an event redirection as unavailable" do
    get "/iloj/mallongilo_disponeblas", params: {id: @event.id, mallongilo: "OLD_ONE"}, headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_includes response.body, UNAVAILABLE_MESSAGE
  end

  test "allows an event to keep its own mallongilo" do
    get "/iloj/mallongilo_disponeblas", params: {id: @event.id, mallongilo: "KUKUN"}, headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_not_includes response.body, UNAVAILABLE_MESSAGE
  end

  test "marks a free mallongilo as available" do
    get "/iloj/mallongilo_disponeblas", params: {id: @event.id, mallongilo: "nova-ligilo"}, headers: TURBO_STREAM_HEADERS

    assert_response :success
    assert_not_includes response.body, UNAVAILABLE_MESSAGE
  end
end
