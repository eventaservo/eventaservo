# frozen_string_literal: true

require "test_helper"

class EventMailer::WeeklySummaryTest < ActionMailer::TestCase
  test "delivers weekly summary in default locale (Esperanto)" do
    user = users(:user)
    email = EventMailer.weekly_summary(user)

    assert_emails 1 do
      email.deliver_now
    end

    body = (email.html_part || email).body.decoded
    assert_equal ["kontakto@eventaservo.org"], email.from
    assert_equal [user.email], email.to
    assert_equal "Tutmonda semajna resumo de eventoj", email.subject
    assert_includes body, "Eventoj kiuj okazos inter"
    assert_includes body, "Diskonigi mian eventon"
    assert_includes body, "Mesaĝo aŭtomate sendita de"
  end

  test "delivers weekly summary in English when specified" do
    user = users(:user)
    email = EventMailer.weekly_summary(user, locale: :en)
    body = (email.html_part || email).body.decoded

    assert_equal "Worldwide weekly event summary", email.subject
    assert_includes body, "Events taking place between"
    assert_includes body, "Share my event"
    assert_includes body, "Message automatically sent by"
  end

  test "delivers weekly summary in Portuguese when user prefers pt_BR" do
    user = users(:user)
    user.mailings = {"locale" => "pt_BR"}
    email = EventMailer.weekly_summary(user)
    body = (email.html_part || email).body.decoded

    assert_equal "Resumo semanal mundial de eventos", email.subject
    assert_includes body, "Eventos que acontecerão entre"
    assert_includes body, "Divulgar meu evento"
    assert_includes body, "Mensagem enviada automaticamente pelo"
  end

  test "send_weekly_summary_to_users enqueues weekly summary for all subscribed users" do
    assert_enqueued_emails User.receives_weekly_summary.count do
      EventMailer.send_weekly_summary_to_users
    end
  end
end
