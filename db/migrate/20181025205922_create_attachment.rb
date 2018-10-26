class CreateAttachment < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :title, index: true
      t.string :file, index: true, null: false
      t.jsonb :metadata
      t.references :attachable, polymorphic: true, index: true, null: false
      t.references :user, index: true, null: false
      t.timestamps
    end
  end
end
