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
      filter_params = params.permit(:title, :event_title)
      @pagy, @reports = pagy(::Event::Reports::SearchQuery.new(filter_params).call)
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
        redirect_to admin_report_path(@report), notice: I18n.t("flash.admin.reports.updated")
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
      redirect_to admin_reports_path, notice: I18n.t("flash.admin.reports.destroyed")
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
  end
end
