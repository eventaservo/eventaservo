# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "regenerate_api_token regenerates token and redirects to edit path" do
    old_token = @user.jwt_token
    
    travel 1.second do
      post regenerate_api_token_path, headers: { "HTTP_REFERER" => edit_user_registration_url }
    end
    
    @user.reload
    assert_not_equal old_token, @user.jwt_token
    
    # Check redirect (303 See Other)
    assert_redirected_to edit_user_registration_path
    assert_response :see_other
    
    follow_redirect!
    assert_response :success
    assert_equal edit_user_registration_path, path
    assert_select ".alert-primary", /#{I18n.t("activerecord.registrations.token_regenerated")}/
  end
end
