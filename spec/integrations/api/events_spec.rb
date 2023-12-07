require "rails_helper"

RSpec.describe "Api::Events", type: :request do
  describe "GET /api/v1/events" do
    let!(:event) { create(:event, :brazila) }

    it "returns a list of events" do
    end

    subject do
      get "/api/v1/events.json",
        params: {
          user_email: users(:user).email, user_token: users(:user).authentication_token,
          komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
          fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
        }

      JSON.parse(@response.body)
    end

    it { is_expected.to be_a(Array) }

    it "should return the event JSON" do
      expect(subject.first["titolo"]).to eq(event.title)
    end
  end

  describe "GET /api/v2/eventoj" do
    before { @token = users(:user).send(:generate_jwt_token) }

    let(:event) { create(:evento) }

    context "when UUID is provided" do
      let(:params) { {uuid: event.uuid} }

      subject do
        get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: @token}, params: params
        JSON.parse(@response.body)
      end

      it "should return only one record" do
        expect(subject.count).to eq(1)
      end
      it "should return the event JSON" do
        expect(subject.first["titolo"]).to eq(event.title)
      end
    end
  end
end
