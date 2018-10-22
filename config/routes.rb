# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: { sessions:      'users/sessions', registrations: 'users/registrations' }

  resources :events

  namespace :admin do
    get 'users', controller: 'users', action: :index
    get 'countries', controller: 'countries', action: :index
  end
end
