class AddPartnerToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :partner, :boolean, default: false
  end
end
