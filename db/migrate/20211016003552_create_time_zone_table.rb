class CreateTimeZoneTable < ActiveRecord::Migration[6.0]
  def change
    create_table :timezones do |t|
      t.string :en, null: false
      t.string :eo, null: false

      t.timestamps
    end
  end
end
