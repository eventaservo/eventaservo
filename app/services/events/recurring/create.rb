module Events
  module Recurring
    class Create < ApplicationService
      attr_reader :master_event, :day_of_month, :days_of_week, :end_date, :end_type, :frequency, :interval

      # @param master_event [Event] Master event
      # @param day_of_month [Integer] Day of month
      # @param days_of_week [Array] Days of week
      # @param end_date [Date] End date
      # @param end_type [String] End type
      # @param frequency [String] Frequency
      # @param interval [Integer] Interval
      def initialize(**kwargs)
        @master_event = kwargs.dig(:master_event)
        @day_of_month = kwargs.dig(:day_of_month)
        @days_of_week = kwargs.dig(:days_of_week)
        @end_date = kwargs.dig(:end_date)
        @end_type = kwargs.dig(:end_type)
        @frequency = kwargs.dig(:frequency)
        @interval = kwargs.dig(:interval)
      end

      def call
        return failure("Master event is already a recurring master") if master_event.is_recurring_master?
        return failure("Master event already has a recurrence") if master_event.recurrence.present?

        ActiveRecord::Base.transaction do
          set_master_event_as_recurring_master
          recurrence = create_event_recurrence_object

          success(recurrence)
        end
      rescue => e
        failure(e.message)
      end

      private

      def set_master_event_as_recurring_master
        master_event.update(is_recurring_master: true)
      end

      # @return [EventRecurrence] EventRecurrence object
      def create_event_recurrence_object
        recurrence = EventRecurrence.new(
          master_event:,
          active: true,
          day_of_month:,
          days_of_week:,
          end_date:,
          end_type:,
          frequency:,
          interval:
        )

        recurrence.save!

        recurrence
      end
    end
  end
end
