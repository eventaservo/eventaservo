get "/importi", to: "events#nova_importado", as: "importi_eventon"
post "/importi", to: "events#importi"
resources :events, path: "e", param: "code" do
  get "partopreni", to: "participants#event", as: "toggle_participant"
  get "follow", to: "followers#event", as: "toggle_follow"
  delete "delete_file/:file_id", to: "events#delete_file", as: "delete_file"
  post "kontakti_organizanton", to: "events#kontakti_organizanton", as: "kontakti_organizanton"
  post "nuligi", to: "events#nuligi", as: "nuligi"
  get "malnuligi", to: "events#malnuligi", as: "malnuligi"
  get "kronologio", to: "events#kronologio"
  post "nova_video", to: "video#create", as: "new_video"
  get "nova_video", to: "video#new"

  resources :reports, controller: "event/report", path: "raportoj", only: [:new, :create, :destroy]
end
