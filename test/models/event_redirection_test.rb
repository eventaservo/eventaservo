# frozen_string_literal: true

# == Schema Information
#
# Table name: event_redirections
#
#  id            :bigint           not null, primary key
#  hits          :integer          default(0), not null
#  new_short_url :string           not null
#  old_short_url :string           not null, uniquely indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "test_helper"

class EventRedirectionTest < ActiveSupport::TestCase
  test "factory should be valid" do
    event_redirection = build(:event_redirection)
    assert event_redirection.valid?
  end

  test "should validate presence of old_short_url" do
    event_redirection = EventRedirection.new(new_short_url: "new_url")
    assert_not event_redirection.valid?
    assert_includes event_redirection.errors[:old_short_url], "devas esti kompletigita"
  end

  test "should validate presence of new_short_url" do
    event_redirection = EventRedirection.new(old_short_url: "old_url")
    assert_not event_redirection.valid?
    assert_includes event_redirection.errors[:new_short_url], "devas esti kompletigita"
  end
end
