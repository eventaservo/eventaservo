require "rails_helper"

RSpec.describe EventsController, type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET #index" do
    subject { get events_path }

    it_behaves_like "authenticated user required"
  end

  describe "GET #show" do
    subject { get event_path(code: event.code) }

    let(:event) { create(:event) }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    context "when the event doesn't exist anymore" do
      before { event.destroy }

      it "redirects to the home page" do
        subject
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #kronologio" do
    subject { get event_kronologio_path(event_code: event.code) }

    let(:event) { create(:event) }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    context "when the event doesn't exist anymore" do
      before { event.destroy }

      it "redirects to the home page" do
        subject
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE #destroy" do
    subject { delete event_path(code: event.code) }

    let(:user) { create(:user) }
    let(:event) { create(:event, user:) }
    let(:service_instance) { double("Events::SoftDelete") }

    before do
      allow(Events::SoftDelete).to receive(:call).and_return(service_instance)
      sign_in user
    end

    it "calls the SoftDelete service with correct parameters" do
      expect(Events::SoftDelete).to receive(:call).with(event:, user:)
      subject
    end

    context "when service returns success" do
      before do
        allow(service_instance).to receive(:success?).and_return(true)
      end

      it "redirects to root path with message" do
        subject
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to be_present
      end
    end

    context "when service returns failure" do
      let(:error_message) { "User is not authorized to delete event" }

      before do
        allow(service_instance).to receive(:success?).and_return(false)
        allow(service_instance).to receive(:error).and_return(error_message)
      end

      it "redirects to event path with error message" do
        subject
        expect(response).to redirect_to(event_path(code: event.ligilo))
        expect(flash[:error]).to eq(error_message)
      end
    end

    context "when user is not authenticated" do
      before { sign_out user }

      it_behaves_like "authenticated user required"
    end
  end
end
