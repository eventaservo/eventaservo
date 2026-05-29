class AddMajorToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :major, :boolean, default: false

    Organization.where("short_name = 'UEA' or short_name = 'TEJO'").update_all(major: true)
  end
end
