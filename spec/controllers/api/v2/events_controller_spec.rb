require "rails_helper"

RSpec.describe "Api::V2::EventsController", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.send(:generate_jwt_token) }

  describe "#index" do
    let(:params) { {} }
    subject { get "/api/v2/eventoj", params: params, headers: {"Authorization" => "Bearer #{token}"} }

    context "when an UUID is provided" do
      it "return an event based on UUID" do
        uuid = SecureRandom.uuid
        create(:event, uuid: uuid)

        params[:uuid] = uuid
        subject

        response_event = JSON.parse(response.body)[0]
        expect(response_event["uuid"]).to eq(uuid)
      end
    end

    context "when a date range is provided" do
      it "return event based on date range" do
        create(:event, date_start: "1999-01-01", date_end: "1999-01-02")
        create(:event, date_start: "2000-01-01", date_end: "2000-01-02")

        params[:komenca_dato] = "1999-01-01"
        params[:fina_dato] = "1999-01-02"
        subject

        expect(JSON.parse(response.body).count).to eq(1)
      end
    end

    context "when a country code is provided" do
      it "return event based on country code" do
        create(:event, country: Country.by_code("US"))
        create(:event, country: Country.by_code("BR"))

        params[:landa_kodo] = "BR"
        subject

        expect(JSON.parse(response.body).count).to eq(1)
      end
    end

    context "when a category is provided" do
      it "return event based on category" do
        create(:event, specolisto: "kurso")
        create(:event, specolisto: "alia speco")

        params[:speco] = "kurso"
        subject

        expect(JSON.parse(response.body).count).to eq(1)
      end
    end
  end
end
