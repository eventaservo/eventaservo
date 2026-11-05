# frozen_string_literal: true

class Event
  class ReportController < ApplicationController
    before_action :authenticate_user!, only: %i[new create destroy]
    before_action :set_event, except: %i[index]
    before_action :set_report, only: %i[destroy]

    def index
      @events = Event.with_reports.includes(reports: :user).order(date_start: :desc)
      @pagy, @events = pagy(@events, limit: 25)
    end

    def new
      @report = @event.reports.new
    end

    def create
      report = @event.reports.new(report_params)
      report.user = @current_user

      if report.save
        NewEventReportNotificationJob.perform_later(report.id)
        Logs::Create.call(text: "Report created", user: current_user, loggable: report)

        redirect_to event_url(code: @event.code), flash: {success: I18n.t("flash.reports.created")}
      else
        @report = report
        render :new, status: :unprocessable_entity, flash: {error: I18n.t("flash.reports.create_error")}
      end
    end

    def destroy
      if @report.destroy
        redirect_to event_url(code: @event.code), flash: {success: I18n.t("flash.reports.destroyed")}
      else
        redirect_to event_url(code: @event.code), flash: {error: I18n.t("flash.reports.destroy_error")}
      end
    end

    private

    def set_event
      @event = Event.by_link(params[:event_code])
    end

    def set_report
      @report = @event.reports.find(params[:id])
    end

    def report_params
      params.require(:event_report).permit(:title, :url)
    end
  end
end
