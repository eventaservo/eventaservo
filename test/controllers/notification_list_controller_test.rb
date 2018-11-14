require 'test_helper'

class NotificationListControllerTest < ActionDispatch::IntegrationTest

  test "should add new recipient" do
    assert_difference('NotificationList.count', 1) do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post new_recipient_url, params: { country_id: countries(:one).id, email: 'test@example.com' }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi ricevos informojn pri novaj eventoj en #{countries(:one).name}", flash[:success]
  end

  test "should not add existing recipient for country" do
    email = "#{SecureRandom.hex(6)}@test.com"
    NotificationList.create(country_id: countries(:brazilo).id, email: email)

    assert_no_difference('NotificationList.count') do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post new_recipient_url, params: { country_id: countries(:brazilo).id, email: email }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi jam ricevas informojn pri novaj eventoj en #{countries(:brazilo).name}", flash[:info]
  end

  test "should remove recipient" do
    assert_difference('NotificationList.count', -1) do
      get delete_recipient_url(notification_list(:one).code)
    end
    assert_redirected_to root_url
  end

  test "devas sendi repoŝtmesaĝon al la nova abonanto de sciiga listo" do
    random_email = "#{SecureRandom.hex(6)}@test.com"
    country      = countries(:brazilo)

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post new_recipient_url, params: { country_id: country.id, email: random_email }
    end

    sent_email = ActionMailer::Base.deliveries.last

    assert_equal "Informoj pri novaj eventoj en #{country.name}", sent_email.subject
    assert_equal random_email, sent_email.to[0]
  end

  test 'ne sendas retpoŝtmesaĝon se jam abonas la liston' do
    random_email = "#{SecureRandom.hex(6)}@test.com"
    country      = countries(:brazilo)
    NotificationList.create(country_id: country.id, email: random_email)

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post new_recipient_url, params: { country_id: country.id, email: random_email }
    end
  end
end
