get "/r", to: redirect("/users/sign_up")
get "/eventoj/:code", to: redirect("/e/%{code}")
get "/e/:code/k", to: redirect("/e/%{code}/kronologio")
get "/vidmaniero/:view_style", to: redirect("/v/%{view_style}")
get "/e/nova", to: redirect("/e/new")
