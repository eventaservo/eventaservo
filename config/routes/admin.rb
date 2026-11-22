namespace :admin do
  root "dashboard#index"
  get "events", controller: "events", action: :index
  patch "events/recover/:event_code", controller: "events", action: :recover, as: "recover_event"

  resources :logs, only: [:index]
  resources :organizations, only: %i[index destroy] do
    member do
      get :delete
    end
  end
  resources :redirections, except: [:show]
  resources :reports, except: [:new, :create]

  resources :users, only: %i[index show edit update] do
    member do
      patch :confirm
      patch :enable
      patch :deactivate
      get :merge
      post :merge
      patch :reset_password
    end
  end

  get "statistics", controller: "statistics", action: :index
  resources :reklamoj do
    get "toggle_active"
  end
end
