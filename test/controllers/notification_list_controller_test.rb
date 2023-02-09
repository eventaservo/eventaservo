# frozen_string_literal: true

require "test_helper"

class NotificationListControllerTest < ActionDispatch::IntegrationTest
  test "should add new recipient" do
    country = Country.all.sample
    assert_difference("NotificationList.count", 1) do
      assert_enqueued_emails 1 do
        post new_recipient_url, params: { country_id: country.id, email: "test@example.com" }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi ricevos informojn pri novaj eventoj en #{country.name}", flash[:success]
  end

  test "should not add existing recipient for country" do
    email = Faker::Internet.email
    country = Country.all.sample
    NotificationList.create!(country_id: country.id, email: email)

    assert_no_difference("NotificationList.count") do
      assert_no_difference "ActionMailer::Base.deliveries.size" do
        post new_recipient_url, params: { country_id: country.id, email: email }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi jam ricevas informojn pri novaj eventoj en #{country.name}", flash[:info]
  end

  test "should remove recipient" do
    notification_user = create(:notification_user)
    assert_difference("NotificationList.count", -1) do
      get delete_recipient_url(notification_user.code)
    end
    assert_redirected_to root_url
  end

  test "devas sendi repoŝtmesaĝon al la nova abonanto de sciiga listo" do
    country = Country.all.sample
    email   = Faker::Internet.email
    assert_enqueued_emails 1 do
      post new_recipient_url, params: { country_id: country.id, email: email }
    end
  end

  test "ne sendas retpoŝtmesaĝon se jam abonas la liston" do
    random_email = Faker::Internet.email
    country      = Country.all.sample
    NotificationList.create!(country_id: country.id, email: random_email)

    assert_no_difference "ActionMailer::Base.deliveries.size" do
      post new_recipient_url, params: { country_id: country.id, email: random_email }
    end
  end
end
