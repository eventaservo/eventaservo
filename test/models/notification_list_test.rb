require 'test_helper'

class NotificationListTest < ActiveSupport::TestCase
  test "should auto generate code when initialized" do
    recipient = NotificationList.new
    assert_not_empty recipient.code
  end

  test "should not be valid without country" do
    recipient = NotificationList.new(email: 'example@example.com')
    assert_not recipient.valid?
    recipient.country_id = countries(:one).id
    assert recipient.valid?
  end

  test "should not be valid without email" do
    recipient = NotificationList.new(country_id: countries(:one).id)
    assert_not recipient.valid?
    recipient.email = 'example@example.com'
    assert recipient.valid?
  end

  test "one email can subscribe to many countries" do
    email = 'example@example.com'
    NotificationList.create(email: email, country_id: countries(:brazilo).id)

    new_recipient = NotificationList.new(email: email, country_id: countries(:hungario).id)
    assert new_recipient.valid?
  end

  test "email cannot subscribe twice to same country" do
    email = 'example@example.com'
    NotificationList.create(email: email, country_id: countries(:brazilo).id)

    new_recipient = NotificationList.new(email: email, country_id: countries(:brazilo).id)
    assert_not new_recipient.valid?
  end

end
