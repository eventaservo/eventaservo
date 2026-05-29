class DeleteImpressions < ActiveRecord::Migration[6.0]
  def up
    drop_table :impressions
  end
end
