ActiveAdmin.register Country do

  actions :all, except: :destroy

  permit_params :name, :code, :continent

  filter :name_cont
  filter :code_eq
  filter :continent_eq

  index do
    id_column
    column :name
    column :code
    column :continent
    actions
 end
end
