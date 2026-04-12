# frozen_string_literal: true

require "test_helper"

class HomeController::SearchTest < ActionDispatch::IntegrationTest
  test "search with empty query is invalid" do
    get serchilo_url
    assert_response :success
    assert_select ".is-invalid"
    assert_select ".invalid-feedback", text: /La serĉa frazo devas enhavi almenaŭ 3 signojn/
  end

  test "search with short query is invalid" do
    get serchilo_url, params: {query: "ab"}
    assert_response :success
    assert_select ".is-invalid"
    assert_select ".invalid-feedback", text: /La serĉa frazo devas enhavi almenaŭ 3 signojn/
  end

  test "search with valid query returns results" do
    create(:event, title: "Esperanto Kongreso")

    get serchilo_url, params: {query: "Esperanto"}
    assert_response :success
    assert_select ".is-invalid", count: 0
    assert_match CGI.escapeHTML("Esperanto Kongreso"), response.body
  end

  test "search with valid query and filters" do
    create(:event, title: "Pasinta Kongreso")

    get serchilo_url, params: {query: "Pasinta", pasintaj: "true", nuligitaj: "true"}
    assert_response :success
    assert_select ".is-invalid", count: 0
    assert_match CGI.escapeHTML("Pasinta Kongreso"), response.body
  end
end
