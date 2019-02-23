# frozen_string_literal: true

require 'test_helper'

class EmailsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test 'informas pri problemo en evento' do
    evento = create(:evento)
    assert_enqueued_emails 1 do
      params = { name: Faker::Name.name, email: Faker::Internet.email, message: Faker::Lorem.paragraph(6) }
      post event_kontakti_organizanton_url(evento.code, params)
    end

    assert_redirected_to event_url(evento.code)
  end
end
