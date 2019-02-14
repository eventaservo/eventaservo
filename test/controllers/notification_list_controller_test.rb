# frozen_string_literal: true

require 'test_helper'

class NotificationListControllerTest < ActionDispatch::IntegrationTest
  test 'should add new recipient' do
    lando = create(:lando)
    assert_difference('NotificationList.count', 1) do
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post new_recipient_url, params: { country_id: lando.id, email: 'test@example.com' }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi ricevos informojn pri novaj eventoj en #{lando.name}", flash[:success]
  end

  test 'should not add existing recipient for country' do
    email = Faker::Internet.email
    country = create(:lando)
    NotificationList.create!(country_id: country.id, email: email)

    assert_no_difference('NotificationList.count') do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post new_recipient_url, params: { country_id: country.id, email: email }
      end
    end
    assert_redirected_to root_url
    assert_equal "Vi jam ricevas informojn pri novaj eventoj en #{country.name}", flash[:info]
  end

  test 'should remove recipient' do
    notification_user = create(:notification_user)
    assert_difference('NotificationList.count', -1) do
      get delete_recipient_url(notification_user.code)
    end
    assert_redirected_to root_url
  end

  test 'devas sendi repoŝtmesaĝon al la nova abonanto de sciiga listo' do
    country = create(:lando)
    email   = Faker::Internet.email
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post new_recipient_url, params: { country_id: country.id, email: email }
    end

    sent_email = ActionMailer::Base.deliveries.last

    assert_equal "Informoj pri novaj eventoj en #{country.name}", sent_email.subject
    assert_equal email, sent_email.to[0]
  end

  test 'ne sendas retpoŝtmesaĝon se jam abonas la liston' do
    random_email = Faker::Internet.email
    country      = create(:lando)
    NotificationList.create!(country_id: country.id, email: random_email)

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post new_recipient_url, params: { country_id: country.id, email: random_email }
    end
  end
end
