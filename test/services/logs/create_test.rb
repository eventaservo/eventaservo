# frozen_string_literal: true

require "test_helper"

class Logs::CreateTest < ActiveSupport::TestCase
  test "creates a new Log" do
    user = create(:user)
    text = "Test log"
    metadata = {foo: "bar"}

    assert_difference("Log.count", 1) do
      Logs::Create.call(text: text, user: user, metadata: metadata)
    end
  end

  test "returns the created Log" do
    user = create(:user)
    text = "Test log"
    metadata = {foo: "bar"}

    result = Logs::Create.call(text: text, user: user, metadata: metadata)

    assert_instance_of Log, result.payload
  end

  test "saves the provided attributes" do
    user = create(:user)
    text = "Test log"
    metadata = {foo: "bar"}

    result = Logs::Create.call(text: text, user: user, metadata: metadata)
    created_log = result.payload

    assert_equal "Test log", created_log.text
    assert_equal({"foo" => "bar"}, created_log.metadata)
    assert_equal user.id, created_log.user_id
  end
end
