ActiveAdmin.register Organization do

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

  actions :all, except: :destroy

  filter :name_cont
  filter :country

  permit_params :name, :short_name, :official, :email, :url, :country_id, :city, :address, :phone

  index do
    column :id
    column :name
    column :short_name
    column :country
    column :city
  end
end
