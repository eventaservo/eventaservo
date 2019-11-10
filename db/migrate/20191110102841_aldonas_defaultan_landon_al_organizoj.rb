class AldonasDefaultanLandonAlOrganizoj < ActiveRecord::Migration[6.0]
  def up
    change_column_default :organizations, :country_id, 99999
    Organization.where(country_id: nil).update_all(country_id: 99999)
  end

  def down
    change_column_default :organizations, :country_id, nil
  end
end
