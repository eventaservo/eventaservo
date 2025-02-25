class AddInternacionalCalendarToEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :international_calendar, :boolean, default: false
  end

  def down
    remove_column :events, :international_calendar
  end
end
