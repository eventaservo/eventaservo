# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_reports_on_event_id  (event_id)
#  index_event_reports_on_user_id   (user_id)
#
require "test_helper"

class Event::ReportTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build_stubbed(:user)
    @event = FactoryBot.build_stubbed(:event, user: @user)
    @report = FactoryBot.build_stubbed(:event_report, event: @event, user: @user)
  end

  test "#can_be_edited_by? returns true if the user is the report's user" do
    assert @report.can_be_edited_by?(@user)
  end

  test "#can_be_edited_by? returns false if the user is not the report's user" do
    assert_not @report.can_be_edited_by?(FactoryBot.build(:user))
  end
end
