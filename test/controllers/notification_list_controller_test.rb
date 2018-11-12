require 'test_helper'

class NotificationListControllerTest < ActionDispatch::IntegrationTest

  test "should add new recipient" do
    assert_difference('NotificationList.count', 1) do
      post new_recipient_url, params: { country_id: countries(:one).id, email: 'test@example.com' }
    end
    assert_redirected_to root_url
  end

  test "should not add existing recipient for country" do
    email = 'test@example.com'
    NotificationList.create(country_id: countries(:brazilo).id, email: email)

    assert_no_difference('NotificationList.count') do
      post new_recipient_url, params: { country_id: countries(:brazilo).id, email: email }
    end
    assert_redirected_to root_url
  end

  test "should remove recipient" do
    assert_difference('NotificationList.count', -1) do
      get delete_recipient_url(notification_list(:one).code)
    end
    assert_redirected_to root_url
  end
end
