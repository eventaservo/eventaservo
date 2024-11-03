require "rails_helper"

RSpec.describe EventsController, type: :request do
  describe "GET #index" do
    subject { get events_path }

    it_behaves_like "authenticated user reuqired"
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
end
