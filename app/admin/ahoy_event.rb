# frozen_string_literal: true

ActiveAdmin.register Ahoy::Event do
  menu parent: "Ahoy"

  actions :index, :show, :destroy

  includes %i[visit user]

  filter :visit_id_eq, label: "Visit #"
  filter :name_cont, label: "Name"
  filter :time
end
