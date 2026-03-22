# frozen_string_literal: true

module EventRecurrences
  # Updates a recurrence rule. When the scheduling pattern changes,
  # soft-deletes future non-detached children and regenerates them
  # with the new dates.
  #
  # @example
  #   EventRecurrences::Update.call(
  #     recurrence: recurrence,
  #     recurrence_params: { days_of_week: [3] }
  #   )
  class Update < ApplicationService
    attr_reader :recurrence, :recurrence_params

    # Fields that affect when events occur — changes require regeneration
    SCHEDULE_FIELDS = %w[frequency interval days_of_week day_of_month
      week_of_month day_of_week_monthly month_of_year].freeze

    # @param recurrence [EventRecurrence] the recurrence to update
    # @param recurrence_params [Hash] new attributes for the recurrence
    def initialize(recurrence:, recurrence_params:)
      @recurrence = recurrence
      @recurrence_params = recurrence_params
    end

    # @return [ApplicationService::Response]
    def call
      ActiveRecord::Base.transaction do
        schedule_changed = schedule_fields_changed?
        recurrence.update!(recurrence_params)

        if schedule_changed
          delete_future_non_detached_children
          reset_generation_horizon
          GenerateChildren.call(recurrence: recurrence.reload)
        end

        success(recurrence)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    rescue => e
      failure(e.message)
    end

    private

    # Checks if any schedule-affecting field is being changed
    #
    # @return [Boolean]
    def schedule_fields_changed?
      SCHEDULE_FIELDS.any? do |field|
        next false unless recurrence_params.key?(field.to_sym) || recurrence_params.key?(field)

        new_value = recurrence_params[field.to_sym] || recurrence_params[field]
        old_value = recurrence.public_send(field)
        new_value.to_s != old_value.to_s
      end
    end

    # Permanently deletes future child events that are not detached
    #
    # @return [void]
    def delete_future_non_detached_children
      recurrence.master_event
        .recurrent_child_events
        .where("date_start >= ?", Time.current)
        .where("metadata->>'detached_from_recurrent_series' IS NULL OR metadata->>'detached_from_recurrent_series' != ?", "true")
        .destroy_all
    end

    # Resets last_generated_date so GenerateChildren recalculates from scratch
    #
    # @return [void]
    def reset_generation_horizon
      recurrence.update_columns(last_generated_date: nil) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
