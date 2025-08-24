# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :name, :country_id, :username

  actions :all, except: %i[new destroy]

  scope :enabled, default: true
  scope :disabled
  scope :abandoned
  scope :not_confirmed

  includes :country

  filter :name_cont, label: "Name"
  filter :email_cont, label: "Email"
  filter :username_cont, label: "Username"
  filter :country
  filter :last_sign_in_at

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

    actions defaults: true do |user|
      span link_to "User", "/uzanto/#{user.username}", target: "_blank", rel: "noopener"
    end
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
          row :username
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
          row :last_sign_in_at
        end
      end
    end
  end

  member_action :confirm, method: :get do
    resource.update(confirmed_at: Time.zone.now)
    redirect_to active_admin_user_path(resource), notice: "User's email marked as confirmed"
  end

  member_action :enable, method: :put do
    UserServices::Enable.call(user: resource)
    redirect_to active_admin_user_path(resource), alert: "User enabled"
  end

  member_action :deactivate, method: :put do
    if UserServices::Disable.call(resource).success?
      redirect_to active_admin_user_path(resource), alert: "User deactivated"
    else
      redirect_to active_admin_user_path(resource),
        alert: "Could not disable the user. Maybe he belongs to an one-member organization."
    end
  end

  member_action :merge, method: %i[get post] do
    if request.get?
      @page_title = "Merge users"
      @user_list = User.where.not(id: resource.id).map { |u| ["#{u.name} (#{u.username})", u.id] }.sort
    elsif request.post?
      resource.merge_to(params["merge_users"]["target_user_id"])
      redirect_to active_admin_user_path(params["merge_users"]["target_user_id"])
    end
  end

  member_action :reset_password, method: :put do
    new_password = resource.name.split(" ").first + rand(1000).to_s
    resource.update!(password: new_password, password_confirmation: new_password)

    redirect_to active_admin_user_path(resource), alert: "New password: #{new_password}"
  end

  sidebar "Actions", only: :show do
    if resource.confirmed_at.nil?
      div link_to "Confirm user's email", confirm_active_admin_user_path(resource),
        data: {confirm: "This will confirm the user's email. Are you sure?"}
    end

    if resource.disabled == true
      div link_to "Enable the user",
        enable_active_admin_user_path(resource),
        method: :put,
        data: {
          confirm: "Enabled the deleted user. Are your sure?"
        }
    end

    if resource.disabled == false
      div link_to "Disable user",
        deactivate_active_admin_user_path(resource),
        method: :put,
        data: {
          confirm: "To be used when a user wants his account to be destroyed. Removes the user from any " \
                   "organization, move all events to system account and disable the user. Are your sure?" \
        }
    end

    div link_to "Merge to another user", merge_active_admin_user_path(resource)
    div link_to "Reset password", reset_password_active_admin_user_path(resource), method: :put,
      data: {confirm: "This will change the user's password. Are you sure?"}
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :country
      f.input :city
      f.input :username
    end

    f.actions
  end
end
