# frozen_string_literal: true

require "test_helper"

class EventMailer::RememorigasUzantojnPriEventoTest < ActionMailer::TestCase
  setup do
    @event = events(:valid_event)
    @user = users(:user)
  end

  test "delivers 2-hour reminder in default locale (Esperanto)" do
    email = nil
    assert_difference -> { Log.count }, 1 do
      assert_emails 1 do
        email = EventMailer.rememorigas_uzantojn_pri_evento(@event.id, @user.email, "2.hours")
        email.deliver_now
      end
    end

    body = (email.html_part || email).body.decoded
    assert_equal "[ES] #{@event.title} baldaŭ komenciĝos", email.subject
    assert_includes body, "Ĝi komenciĝos baldaŭ"
    assert_includes body, "VIDI LA EVENTAN PAĜON"
  end

  test "delivers 1-week reminder in default locale (Esperanto)" do
    email = EventMailer.rememorigas_uzantojn_pri_evento(@event.id, @user.email, "1.week")

    body = (email.html_part || email).body.decoded
    assert_equal "[ES] #{@event.title} komenciĝos post semajno", email.subject
    assert_includes body, "Ĝi komenciĝos post semajno"
  end

  test "delivers 1-month reminder in default locale (Esperanto)" do
    email = EventMailer.rememorigas_uzantojn_pri_evento(@event.id, @user.email, "1.month")

    body = (email.html_part || email).body.decoded
    assert_equal "[ES] #{@event.title} komenciĝos post monato", email.subject
    assert_includes body, "Ĝi komenciĝos post monato"
  end

  test "delivers reminder in English when specified" do
    email = EventMailer.rememorigas_uzantojn_pri_evento(@event.id, @user.email, "2.hours", locale: :en)
    body = (email.html_part || email).body.decoded

    assert_equal "[ES] #{@event.title} will start soon", email.subject
    assert_includes body, "It will start soon"
    assert_includes body, "VIEW EVENT PAGE"
  end

  test "delivers reminder in Portuguese when user prefers pt_BR" do
    @user.mailings = {"locale" => "pt_BR"}
    @user.save!

    email = EventMailer.rememorigas_uzantojn_pri_evento(@event.id, @user.email, "2.hours")
    body = (email.html_part || email).body.decoded

    assert_equal "[ES] #{@event.title} começará em breve", email.subject
    assert_includes body, "Começará em breve"
    assert_includes body, "VER A PÁGINA DO EVENTO"
  end

  test "skips reminder delivery when event does not exist" do
    assert_no_difference -> { Log.count } do
      email = EventMailer.rememorigas_uzantojn_pri_evento(-999, @user.email, "2.hours")
      assert_no_emails do
        email&.deliver_now
      end
    end
  end

  test "skips reminder delivery when event has already passed" do
    past_event = events(:past_event_danio_recent)

    assert_no_difference -> { Log.count } do
      email = EventMailer.rememorigas_uzantojn_pri_evento(past_event.id, @user.email, "2.hours")
      assert_no_emails do
        email&.deliver_now
      end
    end
  end
end
