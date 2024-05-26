# Video - Registritaj prezentaĵoj
get "/video", to: "video#index"
get "/video/:id/forigi", to: "video#destroy"
