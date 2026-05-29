module Housekeeping
  class CleanAhoy < ApplicationService
    KEEP_AHOY_EVENTS_FOR_MONTHS = 2

    def call
      clean_old_show_event_events
    end

    private

    # Cleans old records of "Show event" Ahoy events
    def clean_old_show_event_events
      Ahoy::Event.where(name: "Show event")
        .where("time < ?", KEEP_AHOY_EVENTS_FOR_MONTHS.months.ago)
        .delete_all
    end
  end
end
