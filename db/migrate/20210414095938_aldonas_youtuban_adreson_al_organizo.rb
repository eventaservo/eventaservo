class AldonasYoutubanAdresonAlOrganizo < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :youtube, :string
  end
end
