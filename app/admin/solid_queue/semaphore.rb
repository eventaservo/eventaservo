class SolidQueue::Semaphore
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "expires_at", "id", "id_value", "key", "updated_at", "value"]
  end
end

ActiveAdmin.register SolidQueue::Semaphore do
  menu parent: "SolidQueue", label: "Semaphore"
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :short_name, :official, :logo, :email, :url, :country_id, :city, :address, :phone, :partner, :major, :youtube
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :short_name, :official, :logo, :email, :url, :country_id, :city, :address, :phone, :partner, :major, :youtube]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # actions :all, except: %i[new destroy edit]

  # filter :name_cont, label: "Name"
  # filter :country

  # includes :country

  # permit_params :name, :short_name, :official, :email, :url, :country_id, :city, :address, :phone

  # index do
  #   id_column
  #   column("Name") { |o| link_to(o.name, "/o/#{o.short_name}", target: :_blank, rel: :noopener) }
  #   column :short_name
  #   column :country
  #   column :city
  #   column("Users") { |o| o.users.count }
  #   column("Events") { |o| o.events.count }
  #   actions
  # end

  # show do
  #   columns do
  #     column do
  #       default_main_content
  #     end

  #     column do
  #       panel "Users" do
  #         table_for resource.users do
  #           column("User") do |user|
  #             link_to user.name, active_admin_user_path(user)
  #           end
  #         end
  #       end

  #       panel "Events" do
  #         table_for resource.events.order(:date_start) do
  #           column("Event") { |event| link_to event.title, active_admin_event_path(event) }
  #           column :date_start
  #         end
  #       end
  #     end
  #   end
  # end
end
