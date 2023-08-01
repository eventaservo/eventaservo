require "test_helper"

class Api::V2::EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = FactoryBot.create(:user)
    @token = @user.send(:generate_jwt_token)
  end

  context "#index" do
    should "return an event based on UUID" do
      uuid = SecureRandom.uuid
      FactoryBot.create(:event, uuid: uuid)

      get api_v2_events_path(uuid: uuid), headers: {"Authorization" => "Bearer #{@token}"}
      assert_response :success

      response_event = JSON.parse(response.body)[0]
      assert_equal uuid, response_event["uuid"]
    end

    should "return event based on date range" do
      FactoryBot.create(:event, date_start: "1999-01-01", date_end: "1999-01-02")
      FactoryBot.create(:event, date_start: "2000-01-01", date_end: "2000-01-02")

      get api_v2_events_path(komenca_dato: "1999-01-01", fina_dato: "1999-01-02"), headers: {"Authorization" => "Bearer #{@token}"}
      assert_response :success

      assert_equal 2, Event.count # Total events in DB should be 2
      assert_equal 1, JSON.parse(response.body).count # But only one event should be returned
    end

    should "return event based on country code" do
      FactoryBot.create(:event, country: Country.by_code("US"), date_start: "2023-01-10", date_end: "2023-01-10")
      FactoryBot.create(:event, country: Country.by_code("BR"), date_start: "2023-01-10", date_end: "2023-01-10")

      get api_v2_events_path(landa_kodo: "BR", komenca_dato: "2023-01-01", fina_dato: "2023-01-31"), headers: {"Authorization" => "Bearer #{@token}"}
      assert_response :success

      assert_equal 2, Event.count # Total events in DB should be 2
      assert_equal 1, JSON.parse(response.body).count # But only one event should be returned
    end
  end
end
