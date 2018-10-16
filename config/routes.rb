# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  root to: 'home#index'
end
