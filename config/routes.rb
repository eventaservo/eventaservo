# frozen_string_literal: true

Rails.application.routes.draw do
  # Dynamic error pages
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  root to: 'home#index'

  devise_for :users, controllers: { sessions:           'users/sessions',
                                    registrations:      'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :events, path: 'eventoj', param: 'code'
  # get '/eventoj/:code', to: 'events#show'
  # get '/eventoj/:code/edit', to: 'events#edit', as: 'edit_event'
  # delete '/eventoj/:code', to: 'events#destroy'

  namespace :admin do
    get 'users', controller: 'users', action: :index
    get 'countries', controller: 'countries', action: :index
  end

  # Aldonaĵoj
  match 'upload/:record_id' => 'attachments#upload', as: 'attachment_upload', via: :post
  match 'dosiero/:id/forighu' => 'attachments#destroy', as: 'attachment_destroy', via: :delete

  # Landoj kaj urboj
  get '/lando/:country_name', controller: 'events', action: 'by_country', as: 'events_by_country'
  get '/lando/:country_name/:city_name', controller: 'events', action: 'by_city', as: 'events_by_city'
end
