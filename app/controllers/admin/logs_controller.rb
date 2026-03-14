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
      logs = Log.includes(:user).order(created_at: :desc)
      logs = apply_filters(logs)

      @pagy, @logs = pagy(logs)
    end

    private

    # Applies filter params to the logs query.
    #
    # @param logs [ActiveRecord::Relation] the base logs relation
    # @return [ActiveRecord::Relation] the filtered logs relation
    def apply_filters(logs)
      if params[:user_name].present?
        logs = logs.joins(:user).where("users.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:user_name])}%")
      end
      if params[:text].present?
        logs = logs.where("logs.text ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:text])}%")
      end
      logs = logs.where("logs.created_at >= ?", Time.zone.parse(params[:start_date]).beginning_of_day) if params[:start_date].present?
      logs = logs.where("logs.created_at <= ?", Time.zone.parse(params[:end_date]).end_of_day) if params[:end_date].present?

      logs
    end
  end
end
