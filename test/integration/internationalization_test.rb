# frozen_string_literal: true

require "test_helper"

# Integration tests verifying the core internationalization architecture:
# route locale scoping, admin-only gating, cookie persistence, and navbar selector.
class InternationalizationTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor is restricted to default locale even with locale param" do
    get root_url(locale: :en)

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_nil cookies[:locale]
  end

  test "unauthenticated visitor is restricted to default locale even with locale cookie" do
    cookies[:locale] = "en"

    get root_url

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
  end

  test "non-admin user is restricted to default locale even with locale param" do
    sign_in users(:user)

    get root_url(locale: :en)

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_nil cookies[:locale]
  end

  test "non-admin user is restricted to default locale even with locale cookie" do
    sign_in users(:user)
    cookies[:locale] = "en"

    get root_url

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
  end

  test "admin user can switch locale via locale param and persists in cookie" do
    sign_in users(:admin_user)

    get root_url(locale: :en)

    assert_response :success
    assert_equal :en, @controller.resolve_locale
    assert_equal "en", cookies[:locale]
    assert_select "#navbar-dropdown div", text: "EN"
  end

  test "admin user restores locale from cookie when param is absent" do
    sign_in users(:admin_user)
    get root_url(locale: :pt_BR)
    assert_equal "pt_BR", cookies[:locale]

    get root_url

    assert_response :success
    assert_equal :pt_BR, @controller.resolve_locale
    assert_select "#navbar-dropdown div", text: "PT-BR"
  end

  test "admin user can switch back to default locale (eo) and updates cookie" do
    sign_in users(:admin_user)

    get root_url(locale: :en)
    assert_equal :en, @controller.resolve_locale
    assert_equal "en", cookies[:locale]
    assert_select "#navbar-dropdown div", text: "EN"

    eo_url = UrlLanguageChanger.new(request.original_url, "eo").call
    get eo_url

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_equal "eo", cookies[:locale]
    assert_select "#navbar-dropdown div", text: "EO"

    get root_url
    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_select "#navbar-dropdown div", text: "EO"
  end

  test "admin user falls back to default locale when param is invalid" do
    sign_in users(:admin_user)

    get root_url, params: {locale: "invalid_locale"}

    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_select "#navbar-dropdown div", text: "EO"
  end

  test "default_url_options omits locale when current locale is default locale" do
    I18n.with_locale(:eo) do
      get root_url
      assert_equal({}, @controller.default_url_options)
    end
  end

  test "default_url_options includes locale when current locale is not default locale" do
    I18n.with_locale(:en) do
      get root_url
      assert_equal({locale: :en}, @controller.default_url_options)
    end
  end

  test "navbar language selector is not rendered for unauthenticated visitor" do
    get root_url

    assert_response :success
    assert_select "#navbar-dropdown", count: 0
    assert_select ".dropdown-item", text: "EN", count: 0
  end

  test "navbar language selector is not rendered for non-admin user" do
    sign_in users(:user)

    get root_url

    assert_response :success
    assert_select "#navbar-dropdown", count: 0
    assert_select ".dropdown-item", text: "EN", count: 0
  end

  test "navbar language selector is rendered for admin user with uppercase locale codes" do
    sign_in users(:admin_user)

    get root_url

    assert_response :success
    assert_select "#navbar-dropdown div", text: "EO"
    assert_select ".dropdown-item", text: "EO"
    assert_select ".dropdown-item", text: "EN"
    assert_select ".dropdown-item", text: "PT-BR"
  end

  test "admin user can access user-facing resource routes with locale prefix" do
    sign_in users(:admin_user)

    get "/en/prie"
    assert_response :success
    assert_equal :en, @controller.resolve_locale
    assert_select "#navbar-dropdown div", text: "EN"

    get "/pt_BR/serchilo"
    assert_response :success
    assert_equal :pt_BR, @controller.resolve_locale
    assert_select "#navbar-dropdown div", text: "PT-BR"
  end

  test "canonical paths without locale prefix remain accessible" do
    get "/prie"
    assert_response :success
    assert_equal :eo, @controller.resolve_locale

    get "/serchilo"
    assert_response :success
    assert_equal :eo, @controller.resolve_locale
  end

  test "renders localized footer elements across locales" do
    get root_url
    assert_response :success
    assert_select ".footer", text: /Versio #{Regexp.escape(Eventaservo::Application::VERSION)}/o
    assert_select ".footer", text: /Kontaktu nin/
    assert_select ".footer", text: /Privateco/
    assert_select ".footer", text: /Regularo/

    sign_in users(:admin_user)

    get "/en"
    assert_response :success
    assert_select ".footer", text: /Version #{Regexp.escape(Eventaservo::Application::VERSION)}/o
    assert_select ".footer", text: /Contact us/
    assert_select ".footer", text: /Privacy/
    assert_select ".footer", text: /Terms of Service/

    get "/pt_BR"
    assert_response :success
    assert_select ".footer", text: /Versão #{Regexp.escape(Eventaservo::Application::VERSION)}/o
    assert_select ".footer", text: /Contate-nos/
    assert_select ".footer", text: /Privacidade/
    assert_select ".footer", text: /Termos de uso/
  end

  test "renders localized navbar search input across locales" do
    get root_url
    assert_response :success
    assert_select "input[placeholder='Serĉu eventojn, urbojn aŭ landojn']"
    assert_select "input[aria-label='Serĉi eventojn']"

    sign_in users(:admin_user)

    get "/en"
    assert_response :success
    assert_select "input[placeholder='Search events, cities, or countries']"
    assert_select "input[aria-label='Search events']"

    get "/pt_BR"
    assert_response :success
    assert_select "input[placeholder='Pesquisar eventos, cidades ou países']"
    assert_select "input[aria-label='Pesquisar eventos']"
  end

  test "renders localized user dropdown menu across locales" do
    user = users(:admin_user)
    sign_in user

    get root_url
    assert_response :success
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Mia profilo/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Miaj eventoj/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Redakti mian profilon/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Elsaluti/

    get "/en"
    assert_response :success
    assert_select "#uzantoDropdown + .dropdown-menu", text: /My profile/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /My events/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Edit my profile/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Sign out/

    get "/pt_BR"
    assert_response :success
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Meu perfil/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Meus eventos/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Editar meu perfil/
    assert_select "#uzantoDropdown + .dropdown-menu", text: /Sair/
  end

  test "renders localized breadcrumb world link across locales" do
    event = events(:valid_event)

    get event_path(code: event.ligilo)
    assert_response :success
    assert_select "nav[aria-label='breadcrumb'] .breadcrumb-item", text: "Mondo"

    sign_in users(:admin_user)

    get "/en/e/#{event.ligilo}"
    assert_response :success
    assert_select "nav[aria-label='breadcrumb'] .breadcrumb-item", text: "World"

    get "/pt_BR/e/#{event.ligilo}"
    assert_response :success
    assert_select "nav[aria-label='breadcrumb'] .breadcrumb-item", text: "Mundo"
  end
end
