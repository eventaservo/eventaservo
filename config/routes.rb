# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: { sessions:           'users/sessions',
                                    registrations:      'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :events, except: ['show'], path: 'eventoj'
  get '/eventoj/:code', to: 'events#show'

  namespace :admin do
    get 'users', controller: 'users', action: :index
    get 'countries', controller: 'countries', action: :index
  end

  match 'upload/:record_id' => 'attachments#upload', as: 'attachment_upload', via: :post
end
