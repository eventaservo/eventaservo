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

  test "user can save preferred locale in profile registration form" do
    user = users(:user)
    sign_in user

    put user_registration_path, params: {
      user: {
        locale: "pt_BR"
      }
    }

    assert_redirected_to events_by_username_path(username: user.username)
    assert_equal :pt_BR, user.reload.preferred_locale
  end

  test "browsing pages with locale param does not overwrite user preferred_locale" do
    admin = users(:admin_user)
    admin.update!(mailings: {"locale" => "pt_BR"})
    sign_in admin

    get root_url(locale: :en)
    assert_response :success
    assert_equal :en, @controller.resolve_locale
    assert_equal :pt_BR, admin.reload.preferred_locale
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

  test "renders localized continent buttons on home page across locales" do
    sign_in users(:admin_user)

    get root_url
    assert_response :success
    assert_select "a.button-event-count[href*='azio']", text: /Azio/

    get "/en"
    assert_response :success
    assert_select "a.button-event-count[href*='azio']", text: /Asia/

    get "/pt_BR"
    assert_response :success
    assert_select "a.button-event-count[href*='azio']", text: /Ásia/
  end

  test "renders localized search view across locales" do
    sign_in users(:admin_user)

    get serchilo_path
    assert_response :success
    assert_select "h1", text: "Serĉilo"
    assert_select "input[name='query'][placeholder='Serĉi eventojn aŭ organizojn... (minimume 3 signoj)']"
    assert_select "label", text: "Pasintaj"
    assert_select "label", text: "Nuligitaj"

    get "/en/serchilo"
    assert_response :success
    assert_select "h1", text: "Search"
    assert_select "input[name='query'][placeholder='Search events or organizations... (minimum 3 characters)']"
    assert_select "label", text: "Past"
    assert_select "label", text: "Cancelled"

    get "/pt_BR/serchilo"
    assert_response :success
    assert_select "h1", text: "Busca"
    assert_select "input[name='query'][placeholder='Buscar eventos ou organizações... (mínimo de 3 caracteres)']"
    assert_select "label", text: "Anteriores"
    assert_select "label", text: "Cancelados"
  end

  test "renders localized teachers and speakers directory across locales" do
    sign_in users(:admin_user)

    get instruantoj_kaj_prelegantoj_path
    assert_response :success
    assert_select "h1", text: /Instruantoj kaj prelegantoj/
    assert_select "label", text: "Nomo"
    assert_select "label", text: "Lando"
    assert_select "label", text: "Nivelo"
    assert_select "input[type='submit'][value='Serĉi']"

    get "/en/instruantoj_kaj_prelegantoj"
    assert_response :success
    assert_select "h1", text: /Teachers and speakers/
    assert_select "label", text: "Name"
    assert_select "label", text: "Country"
    assert_select "label", text: "Level"
    assert_select "input[type='submit'][value='Search']"

    get "/pt_BR/instruantoj_kaj_prelegantoj"
    assert_response :success
    assert_select "h1", text: /Professores e palestrantes/
    assert_select "label", text: "Nome"
    assert_select "label", text: "País"
    assert_select "label", text: "Nível"
    assert_select "input[type='submit'][value='Buscar']"
  end

  test "redirects legacy teachers and speakers URL while preserving locale and query string" do
    sign_in users(:admin_user)

    get "/instruistoj_kaj_prelegantoj"
    assert_redirected_to "/instruantoj_kaj_prelegantoj"

    get "/en/instruistoj_kaj_prelegantoj"
    assert_redirected_to "/en/instruantoj_kaj_prelegantoj"
    follow_redirect!
    assert_response :success
    assert_equal :en, @controller.resolve_locale
    assert_equal "en", cookies[:locale]
    assert_select "h1", text: /Teachers and speakers/

    get "/pt_BR/instruistoj_kaj_prelegantoj?name=Zamenhof"
    assert_redirected_to "/pt_BR/instruantoj_kaj_prelegantoj?name=Zamenhof"
    follow_redirect!
    assert_response :success
    assert_equal :pt_BR, @controller.resolve_locale
    assert_equal "pt_BR", cookies[:locale]
    assert_select "h1", text: /Professores e palestrantes/
  end

  test "renders localized announcements view across locales" do
    sign_in users(:admin_user)

    get anoncoj_path
    assert_response :success
    assert_select "h1", text: /Anoncoj kaj konkursoj/
    assert_select ".caption", text: /Listo de nunaj anoncoj kaj konkursoj en Esperantujo\./

    get "/en/anoncoj"
    assert_response :success
    assert_select "h1", text: /Announcements & Contests/
    assert_select ".caption", text: /List of current announcements and contests in Esperanto-land\./

    get "/pt_BR/anoncoj"
    assert_response :success
    assert_select "h1", text: /Anúncios e Concursos/
    assert_select ".caption", text: /Lista de anúncios e concursos atuais no mundo do Esperanto\./
  end

  test "renders localized international calendar across locales" do
    sign_in users(:admin_user)

    get international_calendar_path
    assert_response :success
    assert_select "h1", text: /Internacia Kalendaro/
    assert_select "a", text: "Pasintaj internaciaj eventoj"

    get "/en/ik"
    assert_response :success
    assert_select "h1", text: /International Calendar/
    assert_select "a", text: "Past international events"

    get "/pt_BR/ik"
    assert_response :success
    assert_select "h1", text: /Calendário Internacional/
    assert_select "a", text: "Eventos internacionais anteriores"
  end

  test "renders localized webcal modal in continent view across locales" do
    sign_in users(:admin_user)

    get events_by_continent_path(continent: "reta")
    assert_response :success
    assert_select "#webcalModal .modal-title", text: "Aboni kalendaron"
    assert_select "#webcalModal button", text: "Fermi"

    get "/en/reta"
    assert_response :success
    assert_select "#webcalModal .modal-title", text: "Subscribe to calendar"
    assert_select "#webcalModal button", text: "Close"

    get "/pt_BR/reta"
    assert_response :success
    assert_select "#webcalModal .modal-title", text: "Assinar calendário"
    assert_select "#webcalModal button", text: "Fechar"
  end

  test "renders localized event details page across locales" do
    event = events(:valid_event)
    sign_in users(:admin_user)

    get event_path(code: event.ligilo)
    assert_response :success
    assert_select ".box-header", text: "Informoj"
    assert_select "#partoprenantoj .text-divider", text: /Interesiĝantoj/
    assert_select "#evento .text-divider", text: "Administranto"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-success", text: "JES"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-danger", text: "NE"

    get "/en/e/#{event.ligilo}"
    assert_response :success
    assert_select ".box-header", text: "Details"
    assert_select "#partoprenantoj .text-divider", text: /Interested/
    assert_select "#evento .text-divider", text: "Administrator"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-success", text: "YES"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-danger", text: "NO"

    get "/pt_BR/e/#{event.ligilo}"
    assert_response :success
    assert_select ".box-header", text: "Informações"
    assert_select "#partoprenantoj .text-divider", text: /Interessados/
    assert_select "#evento .text-divider", text: "Administrador"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-success", text: "SIM"
    assert_select "[data-event-user-interested-button-target='question'] a.btn-danger", text: "NÃO"
  end

  test "renders localized event new form across locales" do
    sign_in users(:admin_user)

    get new_event_path
    assert_response :success
    assert_select ".lead", text: /Nova evento, kunveno aŭ okazaĵo/

    get "/en/e/new"
    assert_response :success
    assert_select ".lead", text: /New event or gathering/

    get "/pt_BR/e/new"
    assert_response :success
    assert_select ".lead", text: /Novo evento ou encontro/
  end

  test "renders localized event edit form across locales" do
    event = events(:valid_event)
    sign_in users(:admin_user)

    get edit_event_path(code: event.ligilo)
    assert_response :success
    assert_select ".lead", text: /Redakti/

    get "/en/e/#{event.ligilo}/edit"
    assert_response :success
    assert_select ".lead", text: /Edit/

    get "/pt_BR/e/#{event.ligilo}/edit"
    assert_response :success
    assert_select ".lead", text: /Editar/
  end

  test "renders localized event chronology across locales" do
    event = events(:valid_event)
    sign_in users(:admin_user)

    get "/e/#{event.ligilo}/kronologio"
    assert_response :success
    assert_select "h4", text: "Kronologio"
    assert_select "a", text: "Revidi la eventon"

    get "/en/e/#{event.ligilo}/kronologio"
    assert_response :success
    assert_select "h4", text: "History"
    assert_select "a", text: "View event"

    get "/pt_BR/e/#{event.ligilo}/kronologio"
    assert_response :success
    assert_select "h4", text: "Histórico"
    assert_select "a", text: "Ver evento"
  end

  test "renders localized reports index across locales" do
    sign_in users(:admin_user)

    get reports_path
    assert_response :success
    assert_select ".lead", text: /Eventoj kun raportoj/

    get "/en/raportoj"
    assert_response :success
    assert_select ".lead", text: /Events with reports/

    get "/pt_BR/raportoj"
    assert_response :success
    assert_select ".lead", text: /Eventos com relatos/
  end

  test "renders localized organizations index across locales" do
    sign_in users(:admin_user)

    get organizations_path
    assert_response :success
    assert_select ".es-list h4", text: /ORGANIZOJ/
    assert_select "a", text: /Krei novan organizon/
    assert_select "input[name='serchi'][placeholder='Serĉi organizon']"

    get "/en/o"
    assert_response :success
    assert_select ".es-list h4", text: /ORGANIZATIONS/
    assert_select "a", text: /Create new organization/
    assert_select "input[name='serchi'][placeholder='Search organization']"

    get "/pt_BR/o"
    assert_response :success
    assert_select ".es-list h4", text: /ORGANIZAÇÕES/
    assert_select "a", text: /Criar nova organização/
    assert_select "input[name='serchi'][placeholder='Buscar organização']"
  end

  test "renders localized organization show view and tabs across locales" do
    org = organizations(:sao_paulo_klubo)
    sign_in users(:admin_user)

    get organization_path(short_name: org.short_name)
    assert_response :success
    assert_select "#future-tab", text: /Venontaj/
    assert_select "#past-tab", text: /Pasintaj/
    assert_select "#reports-tab", text: /Raportoj/
    assert_select "a", text: /Redakti/
    assert_select ".box-header", text: "Administrantoj"
    assert_select ".text-divider", text: "Ĉefadministranto(j)"
    assert_select "#shareModalCenterTitle", text: "Aboni organizan kalendaron"

    get "/en/o/#{org.short_name}"
    assert_response :success
    assert_select "#future-tab", text: /Upcoming/
    assert_select "#past-tab", text: /Past/
    assert_select "#reports-tab", text: /Reports/
    assert_select "a", text: /Edit/
    assert_select ".box-header", text: "Administrators"
    assert_select ".text-divider", text: "Main administrator(s)"
    assert_select "#shareModalCenterTitle", text: "Subscribe to organization calendar"

    get "/pt_BR/o/#{org.short_name}"
    assert_response :success
    assert_select "#future-tab", text: /Futuros/
    assert_select "#past-tab", text: /Passados/
    assert_select "#reports-tab", text: /Relatos/
    assert_select "a", text: /Editar/
    assert_select ".box-header", text: "Administradores"
    assert_select ".text-divider", text: "Administrador(es) principal(is)"
    assert_select "#shareModalCenterTitle", text: "Assinar calendário da organização"
  end

  test "renders localized organization new and edit forms across locales" do
    org = organizations(:sao_paulo_klubo)
    sign_in users(:admin_user)

    get new_organization_path
    assert_response :success
    assert_select ".lead", text: /Nova organizo/
    assert_select "label[for='organization_short_name']", text: "Mallonga nomo"

    get edit_organization_path(short_name: org.short_name)
    assert_response :success
    assert_select ".lead", text: /Redakti organizon/

    get "/en/o/new"
    assert_response :success
    assert_select ".lead", text: /New organization/
    assert_select "label[for='organization_short_name']", text: "Short name"

    get "/en/o/#{org.short_name}/edit"
    assert_response :success
    assert_select ".lead", text: /Edit organization/

    get "/pt_BR/o/new"
    assert_response :success
    assert_select ".lead", text: /Nova organização/
    assert_select "label[for='organization_short_name']", text: "Nome curto"

    get "/pt_BR/o/#{org.short_name}/edit"
    assert_response :success
    assert_select ".lead", text: /Editar organização/
  end

  test "renders localized devise sign in, registration, password, and confirmation pages in default locale" do
    get new_user_session_path
    assert_response :success
    assert_select "p", text: /Ensalutu por krei novajn eventojn/
    assert_select "input[type='submit'][value='Ensaluti']"
    assert_select "a", text: /Mi forgesis mian pasvorton/
    assert_select "a", text: /Registriĝu nun/

    get new_user_registration_path
    assert_response :success
    assert_select "p", text: /Registriĝu por krei novajn eventojn/
    assert_select "input[type='submit'][value='Registriĝi']"
    assert_select "a", text: /Ensalutu/

    get new_user_password_path
    assert_response :success
    assert_select "p", text: /Ĉu vi forgesis vian pasvorton\?/
    assert_select "input[type='submit'][value='Ricevu instrukciojn']"

    get new_user_confirmation_path
    assert_response :success
    assert_select "p", text: /Resendu konfirminstrukciojn/
    assert_select "input[type='submit'][value='Resendi']"
  end

  test "renders localized devise account edit form across locales for admin user" do
    sign_in users(:admin_user)

    get edit_user_registration_path
    assert_response :success
    assert_select ".lead", text: "Redakti profilon"
    assert_select "label[for='user_name']", text: "Nomo"
    assert_select "label[for='user_email']", text: "Retadreso"
    assert_select ".text-divider", text: "Mi pretas helpi"
    assert_select ".text-divider", text: "Ligiloj"
    assert_select ".text-divider", text: "Organizoj"
    assert_select "input[type='submit'][value='Ĝisdatigi']"
    assert_select "a", text: "Forviŝi konton"

    get "/en/users/edit"
    assert_response :success
    assert_select ".lead", text: "Edit profile"
    assert_select "label[for='user_name']", text: "Name"
    assert_select "label[for='user_email']", text: "Email"
    assert_select ".text-divider", text: "I am ready to help"
    assert_select ".text-divider", text: "Links"
    assert_select ".text-divider", text: "Organizations"
    assert_select "input[type='submit'][value='Update']"
    assert_select "a", text: "Delete account"

    get "/pt_BR/users/edit"
    assert_response :success
    assert_select ".lead", text: "Editar perfil"
    assert_select "label[for='user_name']", text: "Nome"
    assert_select "label[for='user_email']", text: "E-mail"
    assert_select ".text-divider", text: "Estou pronto para ajudar"
    assert_select ".text-divider", text: "Links"
    assert_select ".text-divider", text: "Organizações"
    assert_select "input[type='submit'][value='Atualizar']"
    assert_select "a", text: "Excluir conta"
  end

  test "renders localized user public profile and personal events page across locales" do
    admin = users(:admin_user)
    user = users(:user)
    sign_in admin

    # Default locale (eo)
    get events_by_username_path(username: user.username)
    assert_response :success
    assert_select "h1", text: user.name

    get user_events_path(username: admin.username)
    assert_response :success
    assert_select "h4", text: "Mia persona eventa paĝo"

    # English (en)
    get "/en/uzanto/#{user.username}"
    assert_response :success
    assert_select "h1", text: user.name

    get "/en/uzanto/#{admin.username}/eventoj"
    assert_response :success
    assert_select "h4", text: "My personal events page"

    # Portuguese (pt_BR)
    get "/pt_BR/uzanto/#{user.username}"
    assert_response :success
    assert_select "h1", text: user.name

    get "/pt_BR/uzanto/#{admin.username}/eventoj"
    assert_response :success
    assert_select "h4", text: "Minha página pessoal de eventos"
  end

  test "renders localized institutional pages across locales for admin user" do
    sign_in users(:admin_user)

    # 1. About page (/prie)
    get prie_path
    assert_response :success
    assert_select "h1", text: "Eventa Servo"
    assert_select "h3", text: "Historio"
    assert_select "h3", text: "Helpantoj"

    get "/en/prie"
    assert_response :success
    assert_select "h1", text: "Eventa Servo"
    assert_select "h3", text: "History"
    assert_select "h3", text: "Helpers"

    get "/pt_BR/prie"
    assert_response :success
    assert_select "h1", text: "Eventa Servo"
    assert_select "h3", text: "História"
    assert_select "h3", text: "Colaboradores"

    # Reset locale to default (eo)
    get "/prie?locale=eo"
    assert_equal :eo, @controller.resolve_locale

    # 2. Terms of service (/terms)
    get terms_path
    assert_response :success
    assert_select "h1", text: "Uzokondiĉoj"
    assert_select "h2", text: "1. Akcepto de la kondiĉoj"

    get "/en/terms"
    assert_response :success
    assert_select "h1", text: "Terms of Service"
    assert_select "h2", text: "1. Acceptance of Terms"

    get "/pt_BR/terms"
    assert_response :success
    assert_select "h1", text: "Termos de Serviço"
    assert_select "h2", text: "1. Aceitação dos Termos"

    # Plain text format (.text)
    get "/terms.text?locale=eo"
    assert_response :success
    assert_includes response.body, "# Uzokondiĉoj"

    get "/en/terms.text"
    assert_response :success
    assert_includes response.body, "# Terms of Service"

    get "/pt_BR/terms.text"
    assert_response :success
    assert_includes response.body, "# Termos de Serviço"

    # Reset locale to default (eo)
    get "/terms?locale=eo"
    assert_equal :eo, @controller.resolve_locale

    # 3. Privacy page (/privateco, /privacy, /license)
    get privateco_path
    assert_response :success
    assert_select "h1", text: "Privateca politiko"

    get "/en/privateco"
    assert_response :success
    assert_select "h1", text: "Privacy Policy"

    get "/pt_BR/privateco"
    assert_response :success
    assert_select "h1", text: "Política de Privacidade"

    # Plain text format (.text)
    get "/privateco.text?locale=eo"
    assert_response :success
    assert_includes response.body, "# Privateca politiko"

    get "/en/privateco.text"
    assert_response :success
    assert_includes response.body, "# Privacy Policy"

    get "/pt_BR/privateco.text"
    assert_response :success
    assert_includes response.body, "# Política de Privacidade"

    # Reset locale to default (eo)
    get "/privateco?locale=eo"
    assert_equal :eo, @controller.resolve_locale

    get "/privacy"
    assert_response :success
    assert_select "h1", text: "Privateca politiko"

    get "/license"
    assert_response :success
    assert_select "h1", text: "Privateca politiko"
  end

  test "renders localized error pages across locales for admin user" do
    sign_in users(:admin_user)

    # 404 Not Found
    get "/404"
    assert_response :not_found
    assert_select "h1", text: "Paĝo ne trovita"

    get "/en/404"
    assert_response :not_found
    assert_select "h1", text: "Page not found"

    get "/pt_BR/404"
    assert_response :not_found
    assert_select "h1", text: "Página não encontrada"

    # Reset locale to default (eo)
    get "/404?locale=eo"
    assert_equal :eo, @controller.resolve_locale

    # 422 Unacceptable
    get "/422"
    assert_response :unprocessable_entity
    assert_select "h1", text: "Neakceptebla peto"

    get "/en/422"
    assert_response :unprocessable_entity
    assert_select "h1", text: "Unacceptable request"

    get "/pt_BR/422"
    assert_response :unprocessable_entity
    assert_select "h1", text: "Solicitação inaceitável"

    # Reset locale to default (eo)
    get "/422?locale=eo"
    assert_equal :eo, @controller.resolve_locale

    # 500 Internal Error
    get "/500"
    assert_response :internal_server_error
    assert_select "h1", text: "Oh! Eraro okazis!"
    assert_select "input[type='submit'][value='Sendi']"

    get "/en/500"
    assert_response :internal_server_error
    assert_select "h1", text: "Oh! An error occurred!"
    assert_select "input[type='submit'][value='Send']"

    get "/pt_BR/500"
    assert_response :internal_server_error
    assert_select "h1", text: "Ops! Ocorreu um erro!"
    assert_select "input[type='submit'][value='Enviar']"
  end

  test "guest users remain on default locale (eo) when visiting institutional and error pages" do
    get "/en/prie"
    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_select "h3", text: "Historio"

    get "/en/terms"
    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_select "h1", text: "Uzokondiĉoj"

    get "/en/privateco"
    assert_response :success
    assert_equal :eo, @controller.resolve_locale
    assert_select "h1", text: "Privateca politiko"

    get "/en/404"
    assert_response :not_found
    assert_equal :eo, @controller.resolve_locale
    assert_select "h1", text: "Paĝo ne trovita"
  end

  test "transactional emails respect recipient preference and explicit locale scopes" do
    event = events(:valid_event)
    user = users(:user)

    # Weekly summary across languages
    eo_mail = EventMailer.weekly_summary(user, locale: :eo)
    assert_equal "Tutmonda semajna resumo de eventoj", eo_mail.subject

    en_mail = EventMailer.weekly_summary(user, locale: :en)
    assert_equal "Worldwide weekly event summary", en_mail.subject

    pt_mail = EventMailer.weekly_summary(user, locale: :pt_BR)
    assert_equal "Resumo semanal mundial de eventos", pt_mail.subject

    # Contact organizer across languages
    eo_contact = EventMailer.kontakti_organizanton(event: event, user: user, message: "Demando", locale: :eo)
    assert_equal "Informo pri via evento en Eventa Servo", eo_contact.subject

    en_contact = EventMailer.kontakti_organizanton(event: event, user: user, message: "Question", locale: :en)
    assert_equal "Information about your event on Eventa Servo", en_contact.subject

    pt_contact = EventMailer.kontakti_organizanton(event: event, user: user, message: "Dúvida", locale: :pt_BR)
    assert_equal "Informações sobre seu evento no Eventa Servo", pt_contact.subject

    # New admin notification across languages
    eo_admin = EventMailer.nova_administranto(event, locale: :eo)
    assert_equal "Vi estas nova eventa administranto", eo_admin.subject

    en_admin = EventMailer.nova_administranto(event, locale: :en)
    assert_equal "You are a new event administrator", en_admin.subject

    pt_admin = EventMailer.nova_administranto(event, locale: :pt_BR)
    assert_equal "Você é o novo administrador do evento", pt_admin.subject

    # Reminder emails across languages
    eo_reminder = EventMailer.rememorigas_uzantojn_pri_evento(event.id, user.email, "2.hours", locale: :eo)
    assert_equal "[ES] #{event.title} baldaŭ komenciĝos", eo_reminder.subject

    en_reminder = EventMailer.rememorigas_uzantojn_pri_evento(event.id, user.email, "2.hours", locale: :en)
    assert_equal "[ES] #{event.title} will start soon", en_reminder.subject

    pt_reminder = EventMailer.rememorigas_uzantojn_pri_evento(event.id, user.email, "2.hours", locale: :pt_BR)
    assert_equal "[ES] #{event.title} começará em breve", pt_reminder.subject
  end
end
