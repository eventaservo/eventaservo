# frozen_string_literal: true

require "test_helper"

class UserServices::EnableTest < ActiveSupport::TestCase
  test "sets disabled as false" do
    user = create(:user, disabled: true)

    UserServices::Enable.call(user: user)

    assert_not user.reload.disabled
  end

  test "returns payload as true" do
    user = create(:user, disabled: true)

    result = UserServices::Enable.call(user: user)

    assert_equal true, result.payload
  end
end
