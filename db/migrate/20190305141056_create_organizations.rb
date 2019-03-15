class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name, null: false, index: true
      t.string :short_name, null: false, index: true
      t.boolean :official, default: false
      t.string :logo
      t.timestamps
    end

    create_table :organization_users do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :user, index: true
      t.boolean :admin, default: false, index: true
      t.timestamps
    end

    create_table :organization_events do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :event, index: true
      t.timestamps
    end
  end
end
