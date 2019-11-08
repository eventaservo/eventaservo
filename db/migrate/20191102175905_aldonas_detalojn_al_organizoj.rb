class AldonasDetalojnAlOrganizoj < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :email, :string
    add_column :organizations, :url, :string
    add_column :organizations, :country_id, :integer
    add_column :organizations, :city, :string
    add_column :organizations, :address, :string
  end
end
