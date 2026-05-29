class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name

      t.timestamps
    end
    add_index :countries, :name
  end
end
