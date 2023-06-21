ActiveAdmin.register Event::Report do
  menu parent: "Events", priority: 2, label: "Reports"

  actions :all, except: %i[new]

  permit_params :title, :url, :user_id

  filter :title_cont, label: "Title"
  filter :url_cont, label: "URL"
  filter :event_title_cont, label: "Event title"
  filter :user_name_cont, label: "User name"

  index do
    id_column
    column :event
    column :title
    column :url
    column :user

    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :url
      f.input :user
    end

    f.actions
  end
end
