class AddDisplayFlagToOrganizationsAndEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :display_flag, :boolean, default: true
    add_column :events, :display_flag, :boolean, default: true
  end
end
