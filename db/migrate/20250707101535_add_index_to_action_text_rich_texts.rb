class AddIndexToActionTextRichTexts < ActiveRecord::Migration[7.2]
  def change
    # Add index to optimize enhavo lookups in kronologio
    # This helps when looking up ActionText::RichText records for events
    add_index :action_text_rich_texts, [:record_type, :record_id, :name],
      name: "index_action_text_rich_texts_on_record_and_name"
  end
end
