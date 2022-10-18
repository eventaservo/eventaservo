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

  test "All user events must be transfered to the system account" do
    FactoryBot.create(:user, system_account: true)

    user = FactoryBot.create(:user)
    3.times { FactoryBot.create(:event, user: user) }

    assert 0, User.system_account.events.count
    assert 3, user.events.count

    user.disable!

    assert true, user.disabled
    assert 0, user.events.count
    assert 3, User.system_account.events.count
  end
end
