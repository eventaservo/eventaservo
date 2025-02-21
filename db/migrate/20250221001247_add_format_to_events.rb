class AddFormatToEvents < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :format, :string
    add_index :events, :format
  end
end
