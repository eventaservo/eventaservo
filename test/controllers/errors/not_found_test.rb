# frozen_string_literal: true

require "test_helper"

class ErrorsController::NotFoundTest < ActionDispatch::IntegrationTest
  test "should get not_found in default locale (Esperanto)" do
    get "/404"
    assert_response :not_found
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Paĝo ne trovita"
  end

  test "should get not_found in English when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/en/404"
    assert_response :not_found
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Page not found"
  end

  test "should get not_found in Portuguese when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/pt_BR/404"
    assert_response :not_found
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Página não encontrada"
  end

  test "should get not_found for js format" do
    get "/404.js"
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "application/javascript", response.media_type
  end

  test "should get not_found for css format" do
    get "/404.css"
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "text/css", response.media_type
  end

  test "should get not_found for JSON format" do
    get "/404.json"
    assert_response :not_found
    assert_equal "application/json", response.media_type
    assert_equal "Not Found", JSON.parse(response.body)["error"]
  end

  test "should return js comment for 404 redirected exceptions on js assets" do
    # Simulate Rails internal routing for a missing asset file
    get "/404", headers: {
      "action_dispatch.original_path" => "/assets/application-oldhash.js"
    }
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "application/javascript", response.media_type
  end

  test "should return css comment for 404 redirected exceptions on css assets" do
    # Simulate Rails internal routing for a missing css asset file
    get "/404", headers: {
      "action_dispatch.original_path" => "/assets/cssbundling-oldhash.css"
    }
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "text/css", response.media_type
  end

  test "should return empty json for 404 redirected exceptions on source maps" do
    get "/404", headers: {
      "action_dispatch.original_path" => "/assets/application.js.map"
    }
    assert_response :not_found
    assert_equal "application/json", response.media_type
    assert_equal({}, JSON.parse(response.body))
  end
end
