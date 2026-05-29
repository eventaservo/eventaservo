# frozen_string_literal: true

module Admin
  # Admin controller for viewing logs.
  #
  # Provides listing and filtering of logs for administrative purposes.
  class LogsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    # Displays all logs with pagination and optional filters.
    #
    # @return [void]
    def index
      filter_params = params.slice(:user_name, :text, :start_date, :end_date).permit!
      @pagy, @logs = pagy(Logs::SearchQuery.new(filter_params).call)

      # Pre-load related events and organizations to avoid N+1 queries
      # since they are stored in a JSONB column (metadata)
      event_ids = @logs.map(&:event_id).compact.uniq
      org_ids = @logs.map(&:organization_id).compact.uniq
      @events = Event.where(id: event_ids).index_by(&:id)
      @organizations = Organization.where(id: org_ids).index_by(&:id)
    end
  end
end
