# frozen_string_literal: true

require 'test_helper'

class NotificationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'malaboni ricevon de novaj eventoj' do
    uzanto    = create(:uzanto)
    lando     = Country.find_by(code: "br")
    nl_record = nil

    assert_difference('NotificationList.count', 1) do
      nl_record = NotificationList.create!(country: lando, email: uzanto.email)
    end

    assert_difference('NotificationList.count', -1) do
      get delete_recipient_url(nl_record.code)
      assert_response :redirect
      assert_redirected_to root_url
    end
  end
end
