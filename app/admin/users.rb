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
      user.events.size
    end
    column("Active?", :active?)
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
          row :webcal_token
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
          row :active?
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

  member_action :merge, method: %i[get post] do
    if request.get?
      @page_title = "Merge users"
      @user_list = User.where.not(id: resource.id).map { |u| [u.name_with_username, u.id] }.sort
    elsif request.post?
      resource.merge_to(params["merge_users"]["target_user_id"])
      redirect_to active_admin_user_path(params["merge_users"]["target_user_id"])
    end
  end

  sidebar "Actions", only: :show do
    if resource.disabled == false
      div link_to "Disable user", deactivate_active_admin_user_path(resource), method: :put, data: { confirm: "Sure?" }
    end

    div link_to "Merge to another user", merge_active_admin_user_path(resource)
  end
end
