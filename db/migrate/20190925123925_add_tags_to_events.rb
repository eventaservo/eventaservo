class AddTagsToEvents < ActiveRecord::Migration[6.0]
  def up
    add_column :events, :specolisto, :string, default: "Kunveno"
    add_index :events, :specolisto

    Event.all.each do |e|
      e.update_column(:specolisto, e.tag_list.to_s)
    end
  end

  def down
    remove_column :events, :specolisto
  end
end
