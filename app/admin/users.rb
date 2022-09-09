ActiveAdmin.register User do

  actions :all, except: :destroy

  filter :name
  filter :email
  filter :username
  filter :country

  index do
    id_column
    column :name
    column :email
    column :city
    column :country
    column :username
    actions
  end

end
