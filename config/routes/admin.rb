namespace :admin do
  root "dashboard#index"
  get "countries", controller: "countries", action: :index
  get "events", controller: "events", action: :index
  patch "events/recover/:event_code", controller: "events", action: :recover, as: "recover_event"

  resources :logs, only: [:index]

  get "statistics", controller: "statistics", action: :index
  get "mockups", controller: "mockups", action: :index
  get "mockups/breadcrumbs", controller: "mockups", action: :breadcrumbs, as: "mockups_breadcrumbs"
  get "mockups/cards", controller: "mockups", action: :cards, as: "mockups_cards"
  get "mockups/tables", controller: "mockups", action: :tables, as: "mockups_tables"
  resources :reklamoj do
    get "toggle_active"
  end
end
