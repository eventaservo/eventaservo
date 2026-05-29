# frozen_string_literal: true

module Admin
  # Admin controller for managing event reports.
  #
  # Provides listing, viewing, updating, and deletion of reports.
  class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_report, only: %i[show edit update destroy]

    # Displays all reports with pagination and optional filters.
    #
    # @return [void]
    def index
      reports = Event::Report.includes(:event, :user).order(created_at: :desc)

      if params[:title].present?
        reports = reports.where("event_reports.title ILIKE ?", "%#{sanitize_sql_like(params[:title])}%")
      end

      if params[:event_title].present?
        reports = reports.joins(:event).where("events.title ILIKE ?", "%#{sanitize_sql_like(params[:event_title])}%")
      end

      @pagy, @reports = pagy(reports)
    end

    # Displays details for a single report.
    #
    # @return [void]
    def show
    end

    # Renders the edit report form.
    #
    # @return [void]
    def edit
      @users = User.order(:name)
    end

    # Updates an existing report.
    #
    # @return [void]
    def update
      if @report.update(report_params)
        redirect_to admin_report_path(@report), notice: "Raporto sukcese ĝisdatigita."
      else
        @users = User.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes a report.
    #
    # @return [void]
    def destroy
      @report.destroy
      redirect_to admin_reports_path, notice: "Raporto sukcese forigita."
    end

    private

    # Finds a report by ID.
    #
    # @return [void]
    def set_report
      @report = Event::Report.find(params[:id])
    end

    # Strong parameters for event report.
    #
    # @return [ActionController::Parameters]
    def report_params
      params.require(:event_report).permit(:title, :url, :user_id)
    end

    # Sanitizes a string for use in a LIKE query.
    #
    # @param value [String]
    # @return [String]
    def sanitize_sql_like(value)
      ActiveRecord::Base.sanitize_sql_like(value)
    end
  end
end
