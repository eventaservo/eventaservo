require "rails_helper"

RSpec.describe "Api::V2::ApiController", type: :request do
  describe "#validas_token" do
    context "when token is missing" do
      subject { get "/api/v2/eventoj" }

      it "returns unauthorized status" do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["eraro"]).to eq("Token mankas")
      end

      it "tracks the event" do
        expect_any_instance_of(Ahoy::Tracker).to receive(:track).with("Token missing", kind: "api")
        subject
      end
    end

    context "when token is invalid" do
      subject { get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "invalid_token"} }

      # before do
      #   allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
      #   get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: token}
      # end

      it "returns unauthorized status" do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["eraro"]).to eq("Token ne validas")
      end

      it "tracks the event" do
        expect_any_instance_of(Ahoy::Tracker).to receive(:track).with("Token invalid", kind: "api")
        subject
      end
    end

    context "when the token is valid" do
      context "and it is provided by the Authorization header" do
        subject { get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "Bearer #{token}"}, params: }

        let(:user) do
          user = create(:user)
          user.send(:generate_jwt_token)
          user.save!

          user
        end
        let(:token) { user.jwt_token }
        let(:params) do
          {
            komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
            fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
          }
        end
        let!(:event) { create(:evento, date_start: Time.zone.yesterday, date_end: Time.zone.tomorrow) }

        it "returns success status" do
          subject
          expect(response).to have_http_status(:success)
        end
      end

      context "and it is provided by the query string" do
        subject { get "/api/v2/eventoj", params: }

        let(:user) do
          user = create(:user)
          user.send(:generate_jwt_token)
          user.save!

          user
        end
        let(:token) { user.jwt_token }
        let(:params) do
          {
            user_token: token,
            komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
            fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
          }
        end
        let!(:event) { create(:evento, date_start: Time.zone.yesterday, date_end: Time.zone.tomorrow) }

        it "returns success status" do
          subject
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
