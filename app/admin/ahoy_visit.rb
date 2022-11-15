ActiveAdmin.register Ahoy::Visit do
  menu parent: "Ahoy"

  filter :country
  filter :city

  index do
    id_column

    column :user
    column :ip
    column :user_agent
    column :referrer
    column :landing_page
    column :browser
    column :os
    column :device_type
    column :country
    column :city
    column :started_at

    actions
  end
end
