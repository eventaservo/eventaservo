# frozen_string_literal: true

require "test_helper"

class HomeController::FilterCanonicalizationTest < ActionDispatch::IntegrationTest
  KALENDARO = {"Cookie" => "vidmaniero=kalendaro"}

  test "redirects reordered tags to the canonical url" do
    first = tags(:kunveno_evento).id
    second = tags(:kurso).id

    get "/eo", params: {s: "#{second},#{first}"}, headers: KALENDARO

    assert_response :moved_permanently
    assert_equal "http://www.example.com/eo?s=#{first}%2C#{second}", response.location
  end

  test "redirects dead parameters away" do
    get "/eo", params: {f: "qualquercoisa"}, headers: KALENDARO

    assert_response :moved_permanently
    assert_equal "http://www.example.com/eo", response.location
  end

  test "returns not found for an unknown organization" do
    get "/eo", params: {o: "neniu_organizo"}, headers: KALENDARO

    assert_response :not_found
  end

  test "keeps a canonical url untouched" do
    get "/eo", params: {s: tags(:kunveno_evento).id.to_s}, headers: KALENDARO

    assert_response :success
  end

  test "caps pagination" do
    get "/eo", params: {page: "40"}, headers: KALENDARO

    assert_response :moved_permanently
    assert_equal "http://www.example.com/eo?page=20", response.location
  end

  test "also redirects crawlers that send a wildcard accept header" do
    get "/eo", params: {f: "x"}, headers: KALENDARO.merge("Accept" => "*/*")

    assert_response :moved_permanently
  end
end
