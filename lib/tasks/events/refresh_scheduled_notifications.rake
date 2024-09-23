namespace :events do
  desc "Refresh scheduled notifications"
  task refresh_scheduled_notifications: :environment do
    # Make logging be displayed in the console
    Rails.logger = Logger.new($stdout)

    SolidQueue::Job.where(queue_name: "event_reminders", finished_at: nil).destroy_all

    Rails.logger.info("Refreshing scheduled notifications")
    Event.venontaj.each do |event|
      EventServices::ScheduleReminders.new(event).call
    end
  end
end
