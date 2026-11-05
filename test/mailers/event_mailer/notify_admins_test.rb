# frozen_string_literal: true

require "test_helper"

class EventMailer::NotifyAdminsTest < ActionMailer::TestCase
  setup do
    @event = events(:valid_event)
  end

  test "delivers new event notification to admin emails in default locale (Esperanto)" do
    email = EventMailer.notify_admins(@event.id, ghisdatigho: false)

    assert_emails 1 do
      email.deliver_now
    end

    body = (email.html_part || email).body.decoded
    assert_equal Constants::ADMIN_EMAILS, email.to
    assert_equal "[ES estraro] Nova evento: #{@event.title}", email.subject
    assert_includes body, "Tiu ĉi informo estas nur por la administrantoj"
  end

  test "delivers update event notification to specific recipient" do
    email = EventMailer.notify_admins(@event.id, ghisdatigho: true)

    assert_emails 1 do
      email.deliver_now
    end

    body = (email.html_part || email).body.decoded
    assert_equal ["yves.nevelsteen@gmail.com"], email.to
    assert_equal "[ES estraro] Ĝisdatiĝo: #{@event.title}", email.subject
    assert_includes body, "Tiu ĉi informo estas nur por la administrantoj"
  end
end
