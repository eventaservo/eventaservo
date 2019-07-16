class AddImportUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :import_url, :string, limit: 100
  end
end
