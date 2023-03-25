# frozen_string_literal: true

ActiveAdmin.register Log do
  actions :all, except: %i[new edit]

  includes :user

  filter :user
  filter :text_cont

  index do
    column("Date (UTC)") { |log| log.created_at.strftime("%d/%m/%Y %H:%M") }
    column :user
    column :text

    actions
  end
end
