# frozen_string_literal: true

require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    host! "localhost:3000"
    cookies[:vidmaniero] = "kartaro"
  end

  class ByContinentTest < EventsControllerTest
    test "should rediret Europe variations to /europe" do
      europe_variations = %w[
        /e%C5%ADropo
        /euxropo
      ]

      europe_variations.each do |continent|
        get continent
        follow_redirect!
        assert_response :success
        assert_equal "/europo", path
      end
    end

    test "should test all continents" do
      valid_continents = %w[
        /afriko
        /ameriko
        /azio
        /europo
        /oceanio
        /reta
      ]

      valid_continents.each do |continent|
        get continent
        assert_response :success
      end
    end

    test "continent names should be case insensitive, redirecting when necessary" do
      get "/Europo"
      follow_redirect!
      assert_response :success
      assert_equal "/europo", path
    end

    test "devas montri la ĉefpaĝon se la kontinento ne ekzistas" do
      get "/NevalidaKontinento"
      assert_redirected_to root_path
      assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
    end
  end

  class ByCountry < EventsControllerTest
    test "should access the land page" do
      get "/ameriko/brazilo"
      assert_response :success

      get "/E%C5%ADropo/%C4%88e%C4%A5io"
      assert_response :success

      get "/euxropo/cxehxio"
      assert_response :success
    end
  end

  class ByUsername < EventsControllerTest
    test "direktas la uzanton al ĉefapaĝo se uzantnomo ne ekzistas" do
      get "/uzanto/ne_valida_uzantnomo"
      assert_redirected_to root_path
      assert_equal "Uzantnomo ne ekzistas", flash[:error]
    end
  end
end
