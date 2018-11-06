# frozen_string_literal: true

Rails.application.routes.draw do
  # Dynamic error pages
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"
  get "/privateco", to: 'home#privateco'
  get '/license', to: 'home#privateco'
  get '/vidmaniero/:view_style', to: 'home#view_style', as: 'view_style'
  get '/prie', to: 'home#prie'
  get '/events.json', to: 'home#events'

  root to: 'home#index'

  devise_for :users, controllers: { sessions:           'users/sessions',
                                    registrations:      'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :events, path: 'eventoj', param: 'code' do
    get 'like', to: 'likes#event', as: 'toggle_like'
    get 'participate', to: 'participants#event', as: 'toggle_participant'
    get 'follow', to: 'followers#event', as: 'toggle_follow'
  end


  namespace :admin do
    resources :users, only: %i[index show]
    # get 'users', controller: 'users', action: :index
    get 'countries', controller: 'countries', action: :index
  end

  # Aldonaĵoj
  match 'upload/:record_id' => 'attachments#upload', as: 'attachment_upload', via: :post
  match 'dosiero/:id/forighu' => 'attachments#destroy', as: 'attachment_destroy', via: :delete

  # Landoj kaj urboj
  get '/lando/:country_name', controller: 'events', action: 'by_country', as: 'events_by_country'
  get '/lando/:country_name/:city_name', controller: 'events', action: 'by_city', as: 'events_by_city'

  # Eventoj de uzantoj
  get '/uzanto/:username', controller: 'events', action: 'by_username', as: 'events_by_username'
end
