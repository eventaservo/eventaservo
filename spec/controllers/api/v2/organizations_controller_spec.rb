require "rails_helper"

RSpec.describe Api::V2::OrganizationsController, type: :request do
  let(:user) { create(:user) }
  let(:token) { user.send(:generate_jwt_token) }

  describe "GET #index" do
    subject { get "/api/v2/organizations", params:, headers: {"Authorization" => "Bearer #{token}"} }

    let!(:uea) { create(:organization, :uea) }
    let!(:bejo) { create(:organization, :bejo) }
    let(:params) { {} }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "returns JSON" do
      subject
      expect(response.content_type).to include("application/json")
    end

    context "when country code is provided" do
      let(:params) { {country_code: "nl"} }

      it "returns only organizations from that country" do
        subject
        expect(JSON.parse(response.body)["organizations"].first["name"]).to eq("Universala Esperanto Asocio")
      end
    end

    context "when a country code is not provided" do
      it "returns all organizations" do
        subject
        expect(JSON.parse(response.body)["organizations"].count).to eq(2)
      end
    end
  end
end
