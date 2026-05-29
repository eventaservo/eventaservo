# frozen_string_literal: true

require "test_helper"

# Integration tests for RSS feeds by country and continent.
class EventsRssControllerTest < ActionDispatch::IntegrationTest
  setup do
    @brazil = countries(:brazil)
    @montenegro = countries(:country_146)
    @online_country = countries(:country_99999)
  end

  # Tests for RSS feed by country
  class ByCountryRssTest < EventsRssControllerTest
    test "returns XML response for valid country" do
      create(:event, :brazila, :future)

      get "/ameriko/Brazilo.xml"

      assert_response :success
      assert_includes response.content_type, "application/xml"
    end

    test "RSS feed contains correct channel information" do
      create(:event, :brazila, :future)

      get "/ameriko/Brazilo.xml"

      assert_includes response.body, "<title>Eventa Servo - Brazilo</title>"
      assert_includes response.body, "Esperantaj eventoj en Brazilo"
      assert_includes response.body, 'version="2.0"'
    end

    test "RSS feed excludes events from other countries" do
      create(:event, :brazila, :future, title: "Brazila Evento")
      create(:event, :japana, :future, title: "Japana Evento")

      get "/ameriko/Brazilo.xml"

      assert_includes response.body, "Brazila Evento"
      assert_not_includes response.body, "Japana Evento"
    end

    test "RSS feed excludes past events" do
      create(:event, :brazila, :future, title: "Estonta Evento")
      create(:event, :brazila, :past, title: "Pasinta Evento")

      get "/ameriko/Brazilo.xml"

      assert_includes response.body, "Estonta Evento"
      assert_not_includes response.body, "Pasinta Evento"
    end

    test "RSS feed excludes cancelled events" do
      create(:event, :brazila, :future, title: "Aktiva Evento")
      create(:event, :brazila, :future, title: "Nuligita Evento", cancelled: true)

      get "/ameriko/Brazilo.xml"

      assert_includes response.body, "Aktiva Evento"
      assert_not_includes response.body, "Nuligita Evento"
    end

    test "returns empty feed for country with no events" do
      get "/europo/Montenegro.xml"

      assert_response :success
      assert_includes response.body, "<title>Eventa Servo - Montenegro</title>"
    end

    test "redirects for invalid country" do
      get "/europo/InvalidCountry.xml"

      assert_response :redirect
    end
  end

  # Tests for RSS feed by continent
  class ByContinentRssTest < EventsRssControllerTest
    test "returns XML response for reta continent" do
      create(:event, :online, :future)

      get "/reta.xml"

      assert_response :success
      assert_includes response.content_type, "application/xml"
    end

    test "RSS feed contains correct channel information for continent" do
      create(:event, :online, :future)

      get "/reta.xml"

      assert_includes response.body, "<title>Eventa Servo - Reta</title>"
      assert_includes response.body, 'version="2.0"'
    end

    test "RSS feed includes online events" do
      event = create(:event, :online, :future, title: "Reta Evento Testo")

      get "/reta.xml"

      assert_includes response.body, "Reta Evento Testo"
      assert_includes response.body, event_url(code: event.code)
    end

    test "RSS feed excludes non-online events" do
      create(:event, :online, :future, title: "Reta Evento")
      create(:event, :brazila, :future, title: "Brazila Evento")

      get "/reta.xml"

      assert_includes response.body, "Reta Evento"
      assert_not_includes response.body, "Brazila Evento"
    end
  end
end
