# frozen_string_literal: true

require "test_helper"

class Logs::CreateTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @event = create(:event)
  end

  test "creates log successfully with all parameters" do
    result = Logs::Create.call(text: "Test log", user: @user, loggable: @event)

    assert result.success?
    log = result.payload
    assert_equal "Test log", log.text
    assert_equal @user, log.user
    assert_equal @event, log.loggable
  end

  test "creates log without text" do
    result = Logs::Create.call(user: @user, loggable: @event)

    assert result.success?
    log = result.payload
    assert_nil log.text
    assert_equal @user, log.user
  end

  test "creates log without user" do
    result = Logs::Create.call(text: "No user log", loggable: @event)

    assert result.success?
    log = result.payload
    assert_equal "No user log", log.text
    assert_nil log.user
    assert_equal @event, log.loggable
  end

  test "creates log without user or loggable uses system account" do
    result = Logs::Create.call(text: "System log only")

    assert result.success?
    log = result.payload
    assert_equal "System log only", log.text
    assert_nil log.user
    assert_nil log.loggable
  end
end
