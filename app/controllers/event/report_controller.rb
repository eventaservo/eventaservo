class Event
  class ReportController < ApplicationController
    layout "event_report"

    before_action :authenticate_user!, only: %i[new create edit update destroy]
    before_action :set_event
    before_action :set_report, only: %i[edit update destroy]

    def index
      redirect_to event_url(@event.code)
    end

    def show
      @report = @event.reports.find(params[:id])
    end

    def new
      @report = @event.reports.new
    end

    def create
      report = @event.reports.new(report_params)
      report.user = @current_user

      if report.save
        redirect_to event_url(@event.code), flash: {success: "La raporto estis sukcese kreita"}
      else
        @report = report
        render :new, status: :unprocessable_entity, flash: {error: "Eraro okazis kreante la raporton"}
      end
    end

    def edit
    end

    def update
      if @report.update(report_params)
        redirect_to event_url(@event.code), flash: {success: "La raporto estis sukcese ĝisdatigita"}
      else
        render :edit, status: :unprocessable_entity
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
      params.require(:event_report).permit(:title, :content)
    end
  end
end
