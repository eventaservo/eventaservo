class CreateAnalytic < ActiveRecord::Migration[5.2]
  def change
    create_table :analytics do |t|
      t.string :browser
      t.string :version
      t.string :platform
      t.string :ip
      t.string :country
      t.string :path
      t.string :vidmaniero

      t.timestamps
    end
  end
end
