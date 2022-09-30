class AddInternacionalCalendarToEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :international_calendar, :boolean, default: false

    Event.kun_speco("Internacia").each do |event|
      event.update(international_calendar: true)
    end
  end

  def down
    remove_column :events, :international_calendar
  end
end
