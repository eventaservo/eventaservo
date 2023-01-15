# frozen_string_literal: true

Rails.application.routes.draw do
  # Dynamic error pages
  get '/robots.txt', to: 'home#robots'
  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_error'
  post "/500", to: "errors#error_form", as: "error_form"
  get '/privateco', to: 'home#privateco'
  get '/license', to: 'home#privateco'
  get '/v/:view_style', to: 'home#view_style', as: 'view_style'
  get '/prie', to: 'home#prie'
  get '/rss.xml', to: 'home#feed', as: 'events_rss'
  get "/novajhoj", to: "home#changes", as: "changes"
  get '/events.json', to: 'home#events'
  get '/statistikoj', to: 'home#statistics'
  get '/akcepti_kuketojn', to: 'home#accept_cookies'
  get '/forigas_kuketojn', to: 'home#reset_cookies'
  get '/serchilo', to: 'home#serchilo'
  get '/search.json', to: 'home#search', format: :json
  get '/versio', to: 'home#versio', format: :json

  authenticated :user, -> user { user.admin? }  do
    mount DelayedJobWeb, at: "/delayed_job"
  end

  ActiveAdmin.routes(self)

  root to: 'home#index'

  devise_for :users, controllers: { sessions:           'users/sessions',
                                    registrations:      'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  # Mallongigoj kaj alidirektoj
  get '/r', to: redirect('/users/sign_up')
  get '/eventoj/:code', to: redirect('/e/%{code}')
  get '/vidmaniero/:view_style', to: redirect('/v/%{view_style}')
  get '/e/nova', to: redirect('/e/new')
  get '/reta', to: redirect('/Reta')

  # API
  namespace :api do
    namespace :v1 do
      get 'events', to: 'events#index'
      get 'uzanto/:id/rekrei_api_kodon', to: 'users#rekrei_api_kodon', as: 'rekrei_api_kodon'

      # Statistikoj
      get 'statistikoj', to: 'statistics#index'
    end

    namespace :v2, defaults: { format: :json } do
      scope 'eventoj' do
        get '/', to: 'events#index'
      end
    end
  end

  # iloj
  namespace :iloj do
    get 'mallongilo_disponeblas', to: 'mallongilo#disponeblas'
    post 'elektas_horzonon', to: 'horzono#elektas'
    get 'forvishas_horzonon', to: 'horzono#forvishas'
  end

  # Webcal
  namespace :webcal do
    get 'lando/:landa_kodo', to: 'webcal#lando'
    get 'o/:short_name', to: 'webcal#organizo', as: 'organizo'
    get "uzanto/:webcal_token", to: "webcal#user", as: "user"
  end

  # International Calendar (Internacia kalendaro)
  get "ik", to: "international_calendar#index", as: "international_calendar"
  get "ik/jaroj", to: "international_calendar#year_list", as: "international_calendar_year_list"
  get "ik/:year", to: "international_calendar#year", as: "international_calendar_year"
  get "kalendaro", to: redirect("/ik")
  get "j", to: redirect("/ik")
  get "j/:year", to: redirect("/ik/%{year}")
  get "/eventoj-hu", to: redirect("/ik/jaroj#eventoj-hu")

  # Anoncoj kaj Konkursoj
  get '/anoncoj', to: 'home#anoncoj', as: 'anoncoj'

  # Instruistoj kaj prelegantoj
  get '/instruistoj_kaj_prelegantoj', to: redirect("/instruantoj_kaj_prelegantoj") , as: 'instruistoj_kaj_prelegantoj'
  get '/instruantoj_kaj_prelegantoj', to: 'home#instruistoj_kaj_prelegantoj', as: 'instruantoj_kaj_prelegantoj'

  # Video - Registritaj prezentaĵoj
  get '/video', to: 'video#index'
  get '/video/:id/forigi', to: 'video#destroy'

  # Organizoj
  defaults format: :json do
    get '/o/cheforganizoj.json', to: 'organizations#cheforganizoj'
  end
  get '/o/search', to: 'organizations#search', as: 'organization_search'
  resources :organizations, path: 'o', param: 'short_name' do
    post 'aldoni_uzanton', to: 'organizations#aldoni_uzanton'
    get 'estrighu/:username', to: 'organizations#estrighu', as: 'estrighu'
    get 'forighu/:username', to: 'organizations#forighu', as: 'forighu'
  end

  # Eventoj
  get '/importi', to: 'events#nova_importado', as: 'importi_eventon'
  post '/importi', to: 'events#importi'
  resources :events, path: 'e', param: 'code' do
    get 'partopreni', to: 'participants#event', as: 'toggle_participant'
    get 'follow', to: 'followers#event', as: 'toggle_follow'
    delete 'delete_file/:file_id', to: 'events#delete_file', as: 'delete_file'
    post 'kontakti_organizanton', to: 'events#kontakti_organizanton', as: 'kontakti_organizanton'
    post 'nuligi', to: 'events#nuligi', as: 'nuligi'
    get 'malnuligi', to: 'events#malnuligi', as: 'malnuligi'
    get 'kronologio', to: 'events#kronologio'
    post 'nova_video', to: 'video#create'
    get 'nova_video', to: 'video#new'
  end

  # Admin
  namespace :admin do
    resources :users, only: %i[index show update] do
      post 'kunigi', action: :kunigi
    end
    get 'sciiga_listo', controller: 'notifications', action: :index, as: 'notification_list'
    get 'countries', controller: 'countries', action: :index
    get 'eventoj', controller: 'events', action: :index
    get 'forigitaj_eventoj', controller: 'events', action: :deleted
    get 'senlokaj_eventoj', to: 'events#senlokaj_eventoj'
    patch 'forigitaj_eventoj/restauri/:event_code', controller: 'events', action: :recover, as: 'recover_event'
    get 'analizado', to: 'analizado#index'
    get 'analizado_lau_retumiloj', to: 'analizado#lau_retumiloj'
    get 'analizado_lau_sistemoj', to: 'analizado#lau_sistemoj'
    get 'analizado_lau_vidmaniero', to: 'analizado#lau_vidmaniero'
    get 'analizado_lau_tago', to: 'analizado#lau_tago'
    resources :reklamoj do
      get "toggle_active"
    end
  end

  # Aldonaĵoj
  match 'upload/:record_id' => 'attachments#upload', as: 'attachment_upload', via: :post
  match 'dosiero/:id/forighu' => 'attachments#destroy', as: 'attachment_destroy', via: :delete

  # Eventoj de uzantoj
  get '/uzanto/:username', controller: 'events', action: 'by_username', as: 'events_by_username'

  # Sciigo
  get '/sciigo/:recipient_code/forigu', controller: 'notification_list', action: :delete, as: 'delete_recipient'
  post '/sciigo', controller: 'notification_list', action: :create, as: 'new_recipient'

  # Landoj kaj urboj
  get '/:continent', to: 'events#by_continent', as: 'events_by_continent'
  get '/:continent/:country_name', controller: 'events', action: 'by_country', as: 'events_by_country'
  # get '/lando/:country_name', controller: 'events', action: 'by_country', as: 'events_by_country'
  get '/:continent/:country_name/:city_name', controller: 'events', action: 'by_city', as: 'events_by_city'
  # get '/lando/:country_name/:city_name', controller: 'events', action: 'by_city', as: 'events_by_city'

end
