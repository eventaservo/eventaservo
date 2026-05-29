class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string :text, index: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
