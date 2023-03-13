# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_lists
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer          not null
#
# Indexes
#
#  index_notification_lists_on_code                  (code)
#  index_notification_lists_on_country_id_and_email  (country_id,email)
#
require "test_helper"

class NotificationListTest < ActiveSupport::TestCase
  test "should auto generate code when initialized" do
    recipient = NotificationList.new
    assert_not_empty recipient.code
  end

  test "should not be valid without country" do
    recipient = NotificationList.new(email: "example@example.com")
    assert_not recipient.valid?
    recipient.country = Country.all.sample
    assert recipient.valid?
  end

  test "should not be valid without email" do
    recipient = NotificationList.new(country_id: Country.find_by(code: "br").id)
    assert_not recipient.valid?
    recipient.email = "example@example.com"
    assert recipient.valid?
  end

  test "one email can subscribe to many countries" do
    email = "example@example.com"
    NotificationList.create!(email: email, country_id: Country.find_by(code: "br").id)

    new_recipient = NotificationList.new(email: email, country_id: Country.find_by(code: "us").id)
    assert new_recipient.valid?
  end

  test "email cannot subscribe twice to same country" do
    email = "example@example.com"
    lando = Country.find_by(code: "br")
    NotificationList.create!(email: email, country_id: lando.id)

    new_recipient = NotificationList.new(email: email, country_id: lando.id)
    assert_not new_recipient.valid?
  end
end
