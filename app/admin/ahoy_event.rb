# frozen_string_literal: true

ActiveAdmin.register Ahoy::Event do
  menu false

  actions :index, :show, :destroy

  includes %i[visit user]

  filter :visit_id_eq, label: "Visit #"
  filter :user, as: :select, collection: proc { Ahoy::Event.users }
  filter :name_eq, label: "Name", as: :select, collection: proc { Ahoy::Event.distinct.pluck(:name).sort }
  filter :time
end
