require "rails_helper"

RSpec.describe Event::ReportController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe "POST #create" do
    let(:params) do
      {
        event_code: event.code,
        event_report: {
          title: "Report title",
          url: "https://uea.org"
        }
      }
    end
    subject { post :create, params: }

    before do
      sign_in user
    end

    it "should enqueue NewEventReportNotificationJob" do
      subject
      expect(NewEventReportNotificationJob).to have_been_enqueued
    end

    it "should create a Log record" do
      subject
      expect(Log.last.text).to eq("Created report Report title")
    end

    it "should redirect to event page" do
      subject
      expect(response).to redirect_to(event_path(code: event.code))
    end

    context "when report is invalid" do
      before do
        params[:event_report][:title] = nil
      end

      it "should respond with :unprocessable_entity" do
        subject
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:report) { create(:event_report, event: event, user: user) }

    it "should destroy the report" do
      sign_in user
      expect do
        delete :destroy, params: {event_code: event.code, id: report.id}
      end.to change(Event::Report, :count).by(-1)
    end
  end
end
