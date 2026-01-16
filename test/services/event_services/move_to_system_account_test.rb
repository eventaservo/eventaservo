# frozen_string_literal: true

require "test_helper"

class EventServices::MoveToSystemAccountTest < ActiveSupport::TestCase
  test "moves the event to the system account" do
    system_account = create(:user, system_account: true)
    event = create(:event)

    EventServices::MoveToSystemAccount.new(event).call

    assert_equal User.system_account.id, event.reload.user_id
  end
end
