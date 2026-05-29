# frozen_string_literal: true

require "test_helper"

class Api::V2::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @token = @user.jwt_token
    @uea = create(:organization, :uea)
    @bejo = create(:organization, :bejo)
  end

  # GET #index tests
  test "index returns http success" do
    get "/api/v2/organizations", headers: {"Authorization" => "Bearer #{@token}"}
    assert_response :success
  end

  test "index returns JSON" do
    get "/api/v2/organizations", headers: {"Authorization" => "Bearer #{@token}"}
    assert_includes response.content_type, "application/json"
  end

  test "index returns only organizations from specified country when country code is provided" do
    get "/api/v2/organizations",
      params: {country_code: "nl"},
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_equal "Universala Esperanto Asocio",
      JSON.parse(response.body)["organizations"].first["name"]
  end

  test "index returns all organizations when country code is not provided" do
    get "/api/v2/organizations", headers: {"Authorization" => "Bearer #{@token}"}
    assert_equal 2, JSON.parse(response.body)["organizations"].count
  end
end
