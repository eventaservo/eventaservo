class Event
  class ReportController < ApplicationController
    before_action :authenticate_user!, only: %i[new create edit update destroy]
    before_action :set_event, except: %i[index]
    before_action :set_report, only: %i[destroy]

    def index
      @events = Event.with_reports.order(date_start: :desc)
      @pagy, @events = pagy(@events, items: 25)
    end

    def new
      @report = @event.reports.new
    end

    def create
      report = @event.reports.new(report_params)
      report.user = @current_user

      if report.save
        NewEventReportNotificationJob.perform_later(report.id)
        Log.create(text: "Created report #{report.title}", user: @current_user, event_id: report.event.id)

        redirect_to event_url(@event.code), flash: {success: "La raporto estis sukcese kreita"}
      else
        @report = report
        render :new, status: :unprocessable_entity, flash: {error: "Eraro okazis kreante la raporton"}
      end
    end

    def destroy
      if @report.destroy
        redirect_to event_url(@event.code), flash: {success: "La raporto estis sukcese forigita"}
      else
        redirect_to event_url(@event.code), flash: {error: "Eraro okazis forigante la raporton"}
      end
    end

    private

    def set_event
      @event = Event.lau_ligilo(params[:event_code])
    end

    def set_report
      @report = @event.reports.find(params[:id])
    end

    def report_params
      params.require(:event_report).permit(:title, :url)
    end
  end
end
