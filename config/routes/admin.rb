namespace :admin do
  get "countries", controller: "countries", action: :index
  get "eventoj", controller: "events", action: :index
  get "forigitaj_eventoj", controller: "events", action: :deleted
  get "senlokaj_eventoj", to: "events#senlokaj_eventoj"
  get "statistics", controller: "statistics", action: :index
  patch "forigitaj_eventoj/restauri/:event_code", controller: "events", action: :recover, as: "recover_event"
  resources :reklamoj do
    get "toggle_active"
  end
end
