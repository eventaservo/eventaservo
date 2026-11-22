namespace :api do
  namespace :v1 do
    get "events", to: "events#index"
    get "uzanto/:id/rekrei_api_kodon", to: "users#rekrei_api_kodon", as: "rekrei_api_kodon"
  end

  namespace :v2, defaults: {format: :json} do
    scope "eventoj" do
      get "/", to: "events#index", as: "events"
    end

    resources :events, param: :uuid, controller: "managed_events", only: %i[index show create update destroy], as: :managed_events do
      member do
        post :cancel
        post :uncancel
      end
    end

    resources :organizations, only: [:index]

    # Catch-all for invalid API v2 endpoints
    match "*path", to: "api#not_found", via: :all
  end
end
