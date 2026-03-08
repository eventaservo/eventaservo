namespace :admin do
  root "dashboard#index"
  get "countries", controller: "countries", action: :index
  get "events", controller: "events", action: :index
  patch "events/recover/:event_code", controller: "events", action: :recover, as: "recover_event"

  get "statistics", controller: "statistics", action: :index
  get "mockups", controller: "mockups", action: :index
  get "mockups/tables", controller: "mockups", action: :tables, as: "mockups_tables"
  get "mockups/breadcrumbs", controller: "mockups", action: :breadcrumbs, as: "mockups_breadcrumbs"
  resources :reklamoj do
    get "toggle_active"
  end
end
