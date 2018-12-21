class AddOnlineToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :online, :boolean, default: false
    add_index :events, :online

    unless Country.exists?(99999)
      Country.create!(id: 99999, name: 'Online', continent: 'Reta', code: 'ol')
    end
  end
end
