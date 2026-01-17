# frozen_string_literal: true

# == Schema Information
#
# Table name: logs
#
#  id            :bigint           not null, primary key
#  loggable_type :string           indexed => [loggable_id]
#  metadata      :jsonb
#  text          :string           indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  loggable_id   :bigint           indexed => [loggable_type]
#  user_id       :bigint           indexed
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class LogTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @event = create(:event)
  end

  test "creates log with user and loggable" do
    log = LogFactory.create(text: "Test log", user: @user, loggable: @event)

    assert log.persisted?
    assert_equal "Test log", log.text
    assert_equal @user, log.user
    assert_equal @event, log.loggable
  end

  test "creates log without text" do
    log = LogFactory.create(user: @user, loggable: @event)

    assert log.persisted?
    assert_nil log.text
    assert_equal @user, log.user
    assert_equal @event, log.loggable
  end

  test "creates log without user" do
    log = LogFactory.create(text: "Auto user log", loggable: @event)

    assert log.persisted?
    assert_equal "Auto user log", log.text
    assert_nil log.user
    assert_equal @event, log.loggable
  end

  test "creates log without user and loggable uses system account" do
    log = LogFactory.create(text: "System log")

    assert log.persisted?
    assert_equal "System log", log.text
    assert_equal User.system_account, log.user
    assert_nil log.loggable
  end

  test "build creates unsaved log" do
    log = LogFactory.build(text: "Unpersisted log", user: @user)

    assert_predicate log, :new_record?
    assert_equal "Unpersisted log", log.text
    assert_equal @user, log.user
  end
end
