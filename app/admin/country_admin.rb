# frozen_string_literal: true

ActiveAdmin.register Country do
  actions :all, except: %i[new destroy edit]

  permit_params :name, :code, :continent

  filter :name_cont, label: "Name"
  filter :code_eq, label: "Code"
  filter :continent_cont, label: "Continent"

  index do
    id_column
    column :name
    column :code
    column :continent
    actions
  end
end
