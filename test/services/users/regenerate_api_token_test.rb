# frozen_string_literal: true

require "test_helper"

class Users::RegenerateApiTokenTest < ActiveSupport::TestCase
  test "regenerates the user's API token" do
    user = create(:user)
    old_token = user.jwt_token
    assert_not_nil old_token

    # Advance time to ensure iat changes
    travel 1.second do
      result = Users::RegenerateApiToken.call(user: user)
      assert result.success?
    end

    user.reload
    assert_not_equal old_token, user.jwt_token
    
    decoded = JWT.decode(user.jwt_token, Rails.application.credentials.dig(:jwt, :secret), true, { algorithm: 'HS256' })
    assert_equal user.id, decoded[0]["id"]
  end

  test "returns failure if user save fails" do
    I18n.with_locale(:en) do
      user = create(:user)
      user.name = nil # Make user invalid so save! raises ActiveRecord::RecordInvalid

      result = Users::RegenerateApiToken.new(user: user).call
      assert_not result.success?
      assert_includes result.error, "Validation failed"
    end
  end
end
