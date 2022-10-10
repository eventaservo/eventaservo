# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :name, :email

  actions :all, except: :destroy

  scope :enabled, default: true
  scope :disabled

  includes :country

  filter :name
  filter :email
  filter :username
  filter :country

  controller do
    def scoped_collection
      User.unscoped
    end
  end

  index do
    id_column
    column :name
    column :email
    column :city
    column :country
    column :username
    column("Events") do |user|
      user.events.count
    end
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :name
          row :email
          row :city
          row :country
          row :user_name
          row :birthday
          row :ueacode
          row :about
          row :ligiloj
          row :instruo
          row :prelego
        end
      end

      column do
        panel "Events" do
          link_to "#{resource.events.count} events", active_admin_events_path("q[user_id_eq]": resource.id)
        end

        panel "Organizations" do
          table_for resource.organizations do
            column("Name") do |o|
              link_to o.name, active_admin_organization_path(o)
            end
            column :short_name
          end
        end

        attributes_table title: "Admin info" do
          row :admin
          row :confirmed_at
          row :disabled
        end
      end
    end
  end

  member_action :deactivate, method: :put do
    if resource.disable!
      redirect_to active_admin_users_path
    else
      redirect_to active_admin_user_path(resource),
                  alert: "Could not disable the user. Maybe he belongs to an one-member organization."
    end
  end

  sidebar "Actions", only: :show do
    if resource.disabled == false
      link_to "Disable user", deactivate_active_admin_user_path(resource), method: :put, data: { confirm: "Sure?" }
    end
  end
end
