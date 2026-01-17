# frozen_string_literal: true

require "test_helper"

class LogFactoryTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @event = create(:event)
  end

  test ".build returns unsaved Log" do
    log = LogFactory.build(text: "Test", user: @user, loggable: @event)

    assert_predicate log, :new_record?
    assert_equal "Test", log.text
    assert_equal @user, log.user
    assert_equal @event, log.loggable
  end

  test ".create returns persisted Log" do
    log = LogFactory.create(text: "Test", user: @user, loggable: @event)

    assert_predicate log, :persisted?
    assert_equal "Test", log.text
    assert_equal @user, log.user
    assert_equal @event, log.loggable
  end
end
