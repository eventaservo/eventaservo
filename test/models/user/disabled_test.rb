# frozen_string_literal: true

require "test_helper"

class User::DisabledTest < ActiveSupport::TestCase
  test "Default scope only to enabled users" do
    assert_equal 1, User.count

    FactoryBot.create(:user)
    assert_equal 2, User.count

    User.last.disable!
    assert_equal 1, User.enabled.count
    assert_equal 1, User.disabled.count
    assert_equal 1, User.count
  end

  test "Email of disabled user must change" do
    user = FactoryBot.create(:user)
    email = user.email

    user.disable!
    assert_not_equal email, user.email
    assert_equal "disabled-#{email}", user.email
  end
end
