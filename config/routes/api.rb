namespace :api do
  namespace :v1 do
    get "events", to: "events#index"
    get "uzanto/:id/rekrei_api_kodon", to: "users#rekrei_api_kodon", as: "rekrei_api_kodon"
  end

  namespace :v2, defaults: {format: :json} do
    scope "eventoj" do
      get "/", to: "events#index", as: "events"
    end

    resources :organizations, only: [:index]
  end
end
