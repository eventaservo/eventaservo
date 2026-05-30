get "/o/search", to: "organizations#search", as: "organization_search"
resources :organizations, path: "o", param: "short_name" do
  post "aldoni_uzanton", to: "organizations#aldoni_uzanton"
  patch "estrighu/:username", to: "organizations#estrighu", as: "estrighu"
  delete "forighu/:username", to: "organizations#forighu", as: "forighu"
end
