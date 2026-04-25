# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  # Normalizes the serialized timezone so that legacy IANA identifiers
  # (e.g. "Asia/Katmandu", "Europe/Kiev") persisted by older enqueues
  # do not crash `Time.use_zone(timezone)` inside `perform_now`.
  #
  # @param job_data [Hash] the serialized ActiveJob payload
  # @return [void]
  def deserialize(job_data)
    super
    return if timezone.blank?

    result = TimeZone::Normalize.call(timezone)
    self.timezone = result.payload if result.success?
  end

  protected

  def default_url_options
    Rails.application.config.active_job.default_url_options
  end
end
