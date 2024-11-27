Rails.application.routes.draw do
  # Dynamic error pages
  get "/robots.txt", to: "home#robots"
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"
  post "/500", to: "errors#error_form", as: "error_form"
  get "/privateco", to: "home#privateco"
  get "/privacy", to: "home#privateco"
  get "/license", to: "home#privateco"
  get "/terms", to: "home#terms"
  get "/v/:view_style", to: "home#view_style", as: "view_style"
  get "/prie", to: "home#prie"
  get "/rss.xml", to: "home#feed", as: "events_rss"
  get "/events.json", to: "home#events"
  get "/serchilo", to: "home#search"
  get "/search.json", to: "home#search", format: :json
  get "/versio", to: "home#versio", format: :json
  get "/dev/error", to: "home#error"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  authenticated :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  ActiveAdmin.routes(self)

  devise_for :users, controllers: {sessions: "users/sessions",
                                   registrations: "users/registrations",
                                   omniauth_callbacks: "users/omniauth_callbacks",
                                   passwords: "users/passwords"}

  namespace :combobox do
    get "users_with_username"
  end

  draw(:api)
  draw(:reports)
  draw(:organizations)

  draw(:shortcuts)

  # iloj
  namespace :iloj do
    get "mallongilo_disponeblas", to: "mallongilo#disponeblas"
    post "elektas_horzonon", to: "horzono#elektas"
    get "forvishas_horzonon", to: "horzono#forvishas"
  end

  # Webcal
  namespace :webcal do
    get "lando/:landa_kodo", to: "webcal#lando"
    get "o/:short_name", to: "webcal#organizo", as: "organizo"
    get "uzanto/:webcal_token", to: "webcal#user", as: "user"
  end

  # Instruistoj kaj prelegantoj
  get "/instruistoj_kaj_prelegantoj", to: redirect("/instruantoj_kaj_prelegantoj"), as: "instruistoj_kaj_prelegantoj"
  get "/instruantoj_kaj_prelegantoj", to: "home#instruistoj_kaj_prelegantoj", as: "instruantoj_kaj_prelegantoj"

  draw(:admin)

  # Aldonaĵoj
  post "upload/:record_id" => "attachments#upload", :as => "attachment_upload"
  delete "dosiero/:id/forighu" => "attachments#destroy", :as => "attachment_destroy"

  # Eventoj de uzantoj
  get "/uzanto/:username", controller: "events", action: "by_username", as: "events_by_username"
  get "/uzanto/:username/eventoj", to: "profile#events", as: "user_events"

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root to: "home#index"

    # Anoncoj kaj Konkursoj
    get "/anoncoj", to: "home#anoncoj", as: "anoncoj"

    # International Calendar (Internacia kalendaro)
    get "ik", to: "international_calendar#index", as: "international_calendar"
    get "ik/jaroj", to: "international_calendar#year_list", as: "international_calendar_year_list"
    get "ik/:year", to: "international_calendar#year", as: "international_calendar_year"
    get "kalendaro", to: redirect("/ik")
    get "j", to: redirect("/ik")
    get "j/:year", to: redirect("/ik/%{year}")
    get "/eventoj-hu", to: redirect("/ik/jaroj#eventoj-hu")

    draw(:videos)

    draw(:events)

    # Countries and cities
    get "/:continent", to: "events#by_continent", as: "events_by_continent"
    get "/:continent/:country_name", controller: "events", action: "by_country", as: "events_by_country"
    get "/:continent/:country_name/:city_name", controller: "events", action: "by_city", as: "events_by_city"
  end
end
