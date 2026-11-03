# frozen_string_literal: true

require "test_helper"

class EventMailer::KontaktiOrganizantonTest < ActionMailer::TestCase
  setup do
    @event = events(:valid_event)
    @user = users(:user)
    @message = "Mi havas demandon pri la evento."
  end

  test "delivers message to organizer in default locale (Esperanto)" do
    email = EventMailer.kontakti_organizanton(event: @event, user: @user, message: @message)

    assert_emails 1 do
      email.deliver_now
    end

    body = (email.html_part || email).body.decoded
    assert_equal [@user.email], email.reply_to
    assert_equal "Informo pri via evento en Eventa Servo", email.subject
    assert_includes body, "Saluton."
    assert_includes body, "Iu havas demandon"
    assert_includes body, @message
  end

  test "delivers message to organizer in English when specified" do
    email = EventMailer.kontakti_organizanton(event: @event, user: @user, message: @message, locale: :en)
    body = (email.html_part || email).body.decoded

    assert_equal "Information about your event on Eventa Servo", email.subject
    assert_includes body, "Hello."
    assert_includes body, "Someone has a question"
    assert_includes body, @message
  end

  test "delivers message to organizer in Portuguese when organizer prefers pt_BR" do
    @event.user.mailings = {"locale" => "pt_BR"}
    email = EventMailer.kontakti_organizanton(event: @event, user: @user, message: @message)
    body = (email.html_part || email).body.decoded

    assert_equal "Informações sobre seu evento no Eventa Servo", email.subject
    assert_includes body, "Olá."
    assert_includes body, "Alguém tem uma dúvida"
    assert_includes body, @message
  end
end
