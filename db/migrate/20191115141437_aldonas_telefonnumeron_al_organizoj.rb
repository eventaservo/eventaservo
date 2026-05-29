class AldonasTelefonnumeronAlOrganizoj < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :phone, :string
  end
end
