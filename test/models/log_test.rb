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
end
