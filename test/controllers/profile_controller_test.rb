require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Tests for the #events action
  class Events < ProfileControllerTest
    def setup
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    test "should get events" do
      get "/uzanto/#{@user.username}/eventoj"

      assert_response :success
    end

    test "redirect to root if the user is not the profile user" do
      another_user = FactoryBot.create(:user)
      get "/uzanto/#{another_user.username}/eventoj"

      assert_redirected_to root_path
      assert_equal "Vi ne rajtas vidi tiun paĝon", flash[:error]
    end

    test "redirect to root if the user is not found" do
      get "/uzanto/ne_valida_uzantnomo/eventoj"

      assert_redirected_to root_path
      assert_equal "Uzanto ne trovita", flash[:error]
    end
  end
end
