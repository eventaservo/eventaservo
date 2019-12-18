class AldonasShortUrlAlEvento < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :short_url, :string, index: true
  end
end
