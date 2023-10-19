ActiveAdmin.register EventRedirection do
  menu parent: "Events", priority: 1, label: "Redirections"

  actions :all, except: [:show]

  permit_params :old_short_url, :new_short_url

  filter :old_short_url
  filter :new_short_url
  filter :hits

  index do
    id_column
    column :old_short_url
    column :new_short_url
    column :hits

    actions
  end
end
