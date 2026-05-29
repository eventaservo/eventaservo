class AddUuidToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :uuid, :uuid, default: "uuid_generate_v4()"
  end
end
