class ChangeImportUrlMaxSizeOnEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :import_url, :string, limit: 400
  end
end
