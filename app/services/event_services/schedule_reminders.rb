module EventServices
  class ScheduleReminders
    # @param [Event] event
    #
    def initialize(event)
      @event = event
    end

    #
    # Deletes all enqueued jobs for the event and creates new ones
    #
    # @return [Boolean]
    #
    def call
      delete_enqueued_jobs

      job_ids = []
      job_ids << create_reminder_job(2.hours, "2.hours")
      job_ids << create_reminder_job(1.week, "1.week")
      job_ids << create_reminder_job(1.month, "1.month")

      update_event_reminder_job_ids(job_ids.compact)
    rescue => e
      Sentry.capture_exception(e)
    end

    #
    # Delete all enqued jobs for the event, based on the event's metadata["event_reminder_job_ids"]
    #
    # @return [Boolean]
    #
    def delete_enqueued_jobs
      return unless @event.event_reminder_job_ids

      schedule_set = Sidekiq::ScheduledSet.new
      @event.event_reminder_job_ids.each do |job_id|
        next unless job_id.is_a?(String)

        schedule_set.scan(job_id).each(&:delete)
      end
    ensure
      update_event_reminder_job_ids([])
    end

    private

    #
    # Updates the event's metadata["event_reminder_job_ids"] with the new value
    #
    # @param [String] new_value
    #
    # @return [Boolean] True if the update was successful, false otherwise
    #
    def update_event_reminder_job_ids(new_value)
      new_event_metadata = @event.metadata
      new_event_metadata["event_reminder_job_ids"] = new_value
      @event.update_column(:metadata, new_event_metadata)
    end

    #
    # Creates a new ActiveJob job to send a reminder to the event's participants
    #
    # @param [Integer] reminder_date Time in seconds before the event starts
    # @param [String] reminder_date_string String representation of the reminder date
    #
    # @return [String | nil] Sidekiq's UUID for the enqueued job (nil if the job was not enqueued)
    #
    def create_reminder_job(reminder_date, reminder_date_string)
      return unless @event.date_start > (DateTime.now + reminder_date)

      job = SciigasUzantojnAntauEventoJob
        .set(wait_until: @event.date_start - reminder_date)
        .perform_later(@event.id, reminder_date_string)

      job.job_id
    end
  end
end
